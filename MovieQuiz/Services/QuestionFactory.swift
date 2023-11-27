import Foundation

// фабрика вопросов
final class QuestionFactory: QuestionFactoryProtocol {
    // слабое свойство с делегатом
    weak var delegate: QuestionFactoryDelegate?
    // свойство с загрузчиком
    private let moviesLoader: MoviesLoading
    // фильмы, загруженные с сервера
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // метод возвращения следующего вопроса, передает его делегату QuestionFactoryDelegate
    func requestNextQuestion() {
        // запускаем код в отдельном потоке
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // выбираем произвольный элемент из массива
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            // используем Subscript для проверки невыхода индекса за пределы массива
            guard let movie = self.movies[safe: index] else { return }
            
            // создание данных из URL
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                self.delegate?.didGetError(with: "Failed to load image")
                return
            }
            
            let rating = Float(movie.rating) ?? 0 // делаем из строки число
            
            // создаем вопрос с разным рейтингом для каждого вопроса и определяем корректность
            let ratingForQuestion = Int.random(in: 7...9)
            let moreOrLessArray: [String] = ["больше", "меньше"]
            let moreOrLessForQuestion = moreOrLessArray.randomElement()
            let text = "Рейтинг этого фильма \(moreOrLessForQuestion!), чем \(ratingForQuestion)?"
            let correctAnswer = moreOrLessForQuestion == "больше" ? rating > Float(ratingForQuestion) : rating < Float(ratingForQuestion)
            
            // создаем модель вопроса
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            // возвращаемся в главный поток и возвращаем вопрос через делегат
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    // метод, инициализирующий загрузку данных
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.errorMessage == "" {
                        self.movies = mostPopularMovies.items // сохраняем фильм в переменную
                        self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                    } else {
                        print(mostPopularMovies.errorMessage) // выводим сообщение об ошибке в консоль
                        self.delegate?.didGetError(with: mostPopularMovies.errorMessage) // сообщаем, что есть ошибка
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
    
}
