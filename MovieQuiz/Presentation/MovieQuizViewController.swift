import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Proprieties
    private var currentQuestionIndex = 0 // индекс текущего вопроса
    private var correctAnswers = 0 // счётчик правильных ответов
    private let questionsAmount = 10 // общее кол-во вопросов квиза
    private var currentQuestion: QuizQuestion? // текущий вопрос для пользователя
    private var questionFactory: QuestionFactoryProtocol? // фабрика вопросов
    private var alertPresenter: AlertPresenter? // показ алерта с результами по окончанию игры
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory() // создаем экземпляр QuestionFactory
        questionFactory?.delegate = self // инъектируем зависимость через свойство
        questionFactory?.requestNextQuestion() // запрашиваем первый вопрос
        alertPresenter = AlertPresenter() // создаем экземпляр AlertPresenter
        alertPresenter?.movieController = self // инъектируем зависимость через свойство
    }
    
    //MARK: - QuestionFactoryDelegate
    // метод делегата QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question // записываем текущий вопрос
        let viewModel = convert(model: question) // конвертируем во вью модель
        // оборачиваем в DispatchQueue.main на случай вызова не из главного потока
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private methods
    // приватный метод конвертации, принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    // приватный метод вывода вопроса на экран
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true // разрешаем рисовать рамку
        imageView.layer.borderWidth = 8 // задаем ширину рамки согласно макету
        imageView.layer.cornerRadius = 20 // задаем скругление рамки согласно макету
        imageView.layer.borderColor = UIColor.clear.cgColor // убираем цвет рамки
        noButton.isEnabled = true // включаем кнопку нет
        yesButton.isEnabled = true // включаем кнопку да
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
    }
    
    // приватный метод, меняющий цвет рамки в зависимости от ответа на вопрос
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false // выключаем кнопку нет для отсутствия доп. нажатий
        yesButton.isEnabled = false // выключаем кнопку да для отсутствия доп. нажатий
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // красим рамку в соответствии с ответом
        
        if isCorrect {
            correctAnswers += 1 // увеличиваем кол-во правильных ответов на 1, если ответ верен
        }
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        // сценарий окончания викторины и показ результатов
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            showResult(quiz: viewModel) // показываем результаты игры

            // сценарий перехода к следующему вопросу
        } else {
            currentQuestionIndex += 1 // идем к следующему вопросу
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // приватный метод для показа результатов раунда квиза
    private func showResult(quiz result: QuizResultsViewModel) {
        // создаем модель для AlertPresenter
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0 // обнуляем текущий индекс вопроса
                self.correctAnswers = 0 // обнуляем кол-во правильных ответов
                questionFactory?.requestNextQuestion() // показываем первый вопрос
            }
        )
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    // MARK: - Actions
    // действия по нажатию кнопки "нет"
    @IBAction private func noButtonDidTape(_ sender: Any) {
        // задаем вопрос, который будем проверять на правильность
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false // т.к. кнопка нет
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // проверяем правильность ответа
    }
    
    // действия по нажатию кнопки "да"
    @IBAction private func yesButtonDidTape(_ sender: Any) {
        // задаем вопрос, который будем проверять на правильность
        guard let currentQuestion = currentQuestion else {
            return
        }
        let giveAnswer = true // т.к. кнопка да
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer) // проверяем правильность ответа
    }
}
