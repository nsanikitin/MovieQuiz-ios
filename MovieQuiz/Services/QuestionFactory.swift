import Foundation

// фабрика вопросов
final class QuestionFactory: QuestionFactoryProtocol {
    // свойство с загрузчиком
    private let moviesLoader: MoviesLoading
    // слабое свойство с делегатом
    weak var delegate: QuestionFactoryDelegate?
    // фильмы, загруженные с сервера
    private var movies: [MostPopularMovie] = []
    
    // массив вопросов из мок-файлов
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше, чем 6?",
//            correctAnswer: false)
//    ]
    
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
            }
            
            let rating = Float(movie.rating) ?? 0 // делаем из строки число
            
            // создаем вопрос с разным рейтингом для каждого вопроса и определяем корректность
            let ratingForQuestion = Int.random(in: 6...8)
            let text = "Рейтинг этого фильма больше чем \(ratingForQuestion)?"
            let correctAnswer = rating > Float(ratingForQuestion)
            
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
                    self.movies = mostPopularMovies.items // сохраняем фильм в переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
}
