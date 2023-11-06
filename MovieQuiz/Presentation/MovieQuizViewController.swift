import UIKit

//структура для вопросов
struct QuizQuestion {
    // строка с названием фильма,
    // совпадает с названием картинки афиши фильма в Assets
    let image: String
    // строка с вопросом о рейтинге фильма
    let text: String
    // булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}

// вью модель для состояния "Вопрос показан"
struct QuizStepViewModel {
    // картинка с афишей фильма с типом UIImage
    let image: UIImage
    // вопрос о рейтинге квиза
    let question: String
    // строка с порядковым номером этого вопроса (ex. "1/10")
    let questionNumber: String
}

// для состояния "Результат квиза"
struct QuizResultsViewModel {
    // строка с заголовком алерта
    let title: String
    // строка с текстом о количестве набранных очков
    let text: String
    // текст для кнопки алерта
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    // переменная с индексом текущего вопроса, начальное значение 0 (по этому индексу будем искать вопрос в массиве)
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    // массив вопросов из мок-файлов
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = convert(model: questions[currentQuestionIndex]) //вью для первого вопроса
        show(quiz: viewModel) // показываем первый вопрос
        imageView.layer.masksToBounds = true // разрешаем рисовать рамку
        imageView.layer.borderWidth = 8 // задаем ширину рамки согласно макету
        imageView.layer.cornerRadius = 20 // задаем скругление рамки согласно макету
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor // убираем цвет рамки
        noButton.isEnabled = true // включаем кнопку нет
        yesButton.isEnabled = true // включаем кнопку да
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false // выключаем кнопку нет для отсутствия доп. нажатий
        yesButton.isEnabled = false // выключаем кнопку да для отсутствия доп. нажатий
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // красим рамку в соответствии с ответом
        
        if isCorrect {
            correctAnswers += 1 // увеличиваем кол-во правильных ответов на 1, если ответ верен
        }
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        // сценарий окончания викторины и показ результатов
        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/10",
                buttonText: "Сыграть ещё раз")
            
            show(quiz: viewModel) // покзываем алерт
            
            // сценарий перехода к следующему вопросу
        } else {
            currentQuestionIndex += 1 // идем к следующему вопросу
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel) // показываем следующий вопрос
        }
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        // задаем параметры для алерта
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        // настройка параметров по нажатию кнопки алерта
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0 //обнуляем текущий индекс вопроса в массиве
            self.correctAnswers = 0 // обнуляем кол-во правильных ответов
            let firstQuestion = self.questions[self.currentQuestionIndex] // возвращаемся к первому вопросу
            let viewModel = self.convert(model: firstQuestion) // делаем вью модель для главного экрана
            self.show(quiz: viewModel) // показываем первый вопрос
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // действия по нажатию кнопки "нет"
    @IBAction private func noButtonDidTape(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex] // задаем вопрос, который будем проверять на правильность
        let givenAnswer = false // т.к. кнопка нет
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) //проверяем правильность ответа
    }
    
    // действия по нажатию кнопки "да"
    @IBAction private func yesButtonDidTape(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex] // задаем вопрос, который будем проверять на правильность
        let giveAnswer = true // т.к. кнопка да
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer) //проверяем правильность ответа
    }
}
