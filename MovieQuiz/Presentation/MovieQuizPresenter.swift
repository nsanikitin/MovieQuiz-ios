import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Proprieties
    private let questionsAmount = 10 // общее кол-во вопросов квиза
    private var correctAnswers = 0 // счётчик правильных ответов
    private var currentQuestionIndex = 0 // индекс текущего вопроса
    private var currentQuestion: QuizQuestion? // текущий вопрос для пользователя
    private var questionFactory: QuestionFactoryProtocol? // фабрика вопросов
    private var statisticService: StatisticService! // статистика по окончанию игры
    private weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController?) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - Methods
    // успешная загрузка данных с сервера
    func didLoadDataFromServer() {
        viewController?.hideLoadIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    // ошибка загрузки данных с сервера
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    // ошибка в запросе через API
    func didGetError(with error: String) {
        viewController?.showDataError(message: error)
    }
    
    // определение последнего вопроса
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // переход к следующему вопросу
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // перезапуск квиза
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // конвертация модели для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    // получение следующего вопроса
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        viewController?.hideLoadIndicator() // выключаем индикатор загрузки
        currentQuestion = question // записываем текущий вопрос
        let viewModel = convert(model: question) // конвертируем во вью модель
        
        // оборачиваем в DispatchQueue.main на случай вызова не из главного потока
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // переход к следующему вопросу или результату
    private func proceedToNextQuestionOrResults() {
        // сценарий окончания викторины и показ результатов
        if self.isLastQuestion() {
            // запись результатов в UserDefaults
            statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            
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
            
            viewController?.showResult(quiz: viewModel) // показываем результаты игры
            
            // сценарий перехода к следующему вопросу
        } else {
            self.switchToNextQuestion() // идем к следующему вопросу
            viewController?.showLoadIndicator() // включаем индикатор загрузки
            questionFactory?.requestNextQuestion() // запрашиваем следующий вопрос
        }
    }
    
    // логика по результату ответа на вопрос
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.turnOffButtons()
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        // запускаем задачу через 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // получен ответ
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let giveAnswer = isYes
        let isCorrect = giveAnswer == currentQuestion.correctAnswer
        
        if isCorrect {
            correctAnswers += 1
        }
        
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    // MARK: - Actions
    // по нажатию кнопки "нет"
    func noButtonDidTape() {
        didAnswer(isYes: false)
    }
    
    // по нажатию кнопки "да"
    func yesButtonDidTape() {
        didAnswer(isYes: true)
    }
    
}
