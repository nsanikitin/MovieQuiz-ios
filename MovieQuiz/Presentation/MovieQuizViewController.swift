import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Proprieties
    // статус бар в белый цвет
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    private var currentQuestionIndex = 0 // индекс текущего вопроса
    private var correctAnswers = 0 // счётчик правильных ответов
    private let questionsAmount = 10 // общее кол-во вопросов квиза
    private var currentQuestion: QuizQuestion? // текущий вопрос для пользователя
    private var questionFactory: QuestionFactoryProtocol? // фабрика вопросов
    private var alertPresenter: AlertPresenter? // показ алерта с результами по окончанию игры
    private var statisticService: StatisticService? // статистика по окончанию игры
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadIndicator() // показываем индикатор загрузки
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self) // создаем экземпляр QuestionFactory
        questionFactory?.loadData() // загружаем данные фильмов через API IMDb
        
        alertPresenter = AlertPresenter() // создаем экземпляр AlertPresenter
        alertPresenter?.viewController = self // инъектируем зависимость через свойство
        
        statisticService = StatisticServiceImplementation() // создаем экземпляр StatisticService
        
        imageView.layer.masksToBounds = true // разрешаем рисовать рамку
        imageView.layer.borderWidth = 8 // задаем ширину рамки согласно макету
        imageView.layer.cornerRadius = 20 // задаем скругление рамки согласно макету
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
    
    // метод успешной загрузки
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    // метод ошибки загрузки
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private methods
    // приватный метод конвертации модели для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    // приватный метод вывода вопроса на экран
    private func show(quiz step: QuizStepViewModel) {
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
    
    // приватный метод логики показа следующего вопроса или результатов
    private func showNextQuestionOrResults() {
        // сценарий окончания викторины и показ результатов
        if currentQuestionIndex == questionsAmount - 1 {
            // запись результатов в UserDefaults
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
                print("Ошибка записи результатов")
                return
            }
            
            let text =  """
                        Ваш результат: \(correctAnswers)/\(questionsAmount)
                        Количество сыгранных квизов: \(statisticService.gamesCount)
                        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                        """
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
        
        alertPresenter?.showAlert(alertModel: alertModel) // показываем алерт с результами
    }
    
    // приватный метод показа индикатора загрузки
    private func showLoadIndicator() {
        activityIndicator.isHidden = false // индикатор закрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию индикатора
    }
    
    // приватный метод скрытия индикатора загрузки
    private func hideLoadIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию индикатора
        activityIndicator.isHidden = true // индикатор закрузки скрыт
    }
    
    // приватный метод показа алерта при ошибке загрузки данных из сети
    private func showNetworkError(message: String) {
        hideLoadIndicator()
        
        // создаем модель для AlertPresenter
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать ещё раз",
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
