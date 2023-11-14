import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Variables
    private var currentQuestionIndex = 0 // переменная с индексом текущего вопроса
    private var correctAnswers = 0 // переменная со счётчиком правильных ответов
    private var questionsAmount = 10 // общее кол-во вопросов квиза
    private var questionFactory: QuestionFactoryProtocol? // фабрика вопросов
    private var currentQuestion: QuizQuestion? // вопрос, который видит пользователь
    
    // MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory()
        questionFactory?.delegate = self // для инъекции зависимостей
        questionFactory?.requestNextQuestion() // показываем первый вопрос
    }
    
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private functions
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
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
    
    // приватный метод, который меняет цвет рамки, принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false // выключаем кнопку нет для отсутствия доп. нажатий
        yesButton.isEnabled = false // выключаем кнопку да для отсутствия доп. нажатий
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // красим рамку в соответствии с ответом
        
        if isCorrect {
            correctAnswers += 1 // увеличиваем кол-во правильных ответов на 1, если ответ верен
        }
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
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
            
            show(quiz: viewModel) // покзываем алерт
            
            // сценарий перехода к следующему вопросу
        } else {
            currentQuestionIndex += 1 // идем к следующему вопросу
            self.questionFactory?.requestNextQuestion()
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
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.currentQuestionIndex = 0 // обнуляем текущий индекс вопроса в массиве
            self.correctAnswers = 0 // обнуляем кол-во правильных ответов
            
            // сбрасываем до первого вопроса и показываем его
            questionFactory?.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
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
