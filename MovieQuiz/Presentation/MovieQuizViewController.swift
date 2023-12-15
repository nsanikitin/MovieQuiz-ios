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
    
    private let presenter = MovieQuizPresenter() // presenter
    private var correctAnswers = 0 // счётчик правильных ответов
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
        
        presenter.viewController = self
        
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
        
        hideLoadIndicator() // выключаем индикатор загрузки
        currentQuestion = question // записываем текущий вопрос
        let viewModel = presenter.convert(model: question) // конвертируем во вью модель
        // оборачиваем в DispatchQueue.main на случай вызова не из главного потока
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // метод успешной загрузки
    func didLoadDataFromServer() {
        hideLoadIndicator() // выключаем индикатор загрузки
        questionFactory?.requestNextQuestion()
        showLoadIndicator() // включаем индикатор загрузки
    }
    
    // метод ошибки загрузки
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // показываем алерт с ошибкой
    }
    
    // метод получения ошибки
    func didGetError(with error: String) {
        showDataError(message: error)
    }
    
    // MARK: - Private methods

    
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
    func showAnswerResult(isCorrect: Bool) {
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
        if presenter.isLastQuestion() {
            // запись результатов в UserDefaults
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
                print("Ошибка записи результатов")
                return
            }
            
            let text =  """
                        Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
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
            presenter.switchToNextQuestion() // идем к следующему вопросу
            showLoadIndicator() // включаем индикатор загрузки
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
                self.presenter.resetQuestionIndex() // обнуляем текущий индекс вопроса
                self.correctAnswers = 0 // обнуляем кол-во правильных ответов
                questionFactory?.requestNextQuestion() // показываем первый вопрос
            }
        )
        
        alertPresenter?.showAlert(alertModel: alertModel) // показываем алерт с результами
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
                self.presenter.resetQuestionIndex() // обнуляем текущий индекс вопроса
                self.correctAnswers = 0 // обнуляем кол-во правильных ответов
                showLoadIndicator()
                questionFactory?.requestNextQuestion() // показываем первый вопрос
            }
        )
        
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    // приватный метод показа алерта при ошибке загрузки данных изображения
    private func showDataError(message: String) {
        hideLoadIndicator()
        
        // создаем модель для AlertPresenter
        let alertModel = AlertModel(
            title: "Ошибка в загрузке данных",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                showLoadIndicator()
                questionFactory?.loadData() // пробуем загрузить данные снова
            }
        )
        
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    // приватный метод показа индикатора загрузки
    private func showLoadIndicator() {
        activityIndicator.startAnimating() // включаем анимацию индикатора и показываем его
    }
    
    // приватный метод скрытия индикатора загрузки
    private func hideLoadIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию индикатора и скрываем его
    }
    
    // MARK: - Actions
    // действия по нажатию кнопки "нет"
    @IBAction private func noButtonDidTape(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonDidTape()
    }
    
    // действия по нажатию кнопки "да"
    @IBAction private func yesButtonDidTape(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonDidTape()
    }
}
