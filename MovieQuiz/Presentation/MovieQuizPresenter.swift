import UIKit

final class MovieQuizPresenter {
    // MARK: - Proprieties
    
    let questionsAmount = 10 // общее кол-во вопросов квиза
    private var currentQuestionIndex = 0 // индекс текущего вопроса
    var currentQuestion: QuizQuestion? // текущий вопрос для пользователя
    weak var viewController: MovieQuizViewController?
    
    // MARK: - Private methods
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // приватный метод конвертации модели для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    // MARK: - Actions
    // действия по нажатию кнопки "нет"
    func noButtonDidTape() {
        // задаем вопрос, который будем проверять на правильность
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false // т.к. кнопка нет
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // проверяем правильность ответа
    }
    
    // действия по нажатию кнопки "да"
    func yesButtonDidTape() {
        // задаем вопрос, который будем проверять на правильность
        guard let currentQuestion = currentQuestion else {
            return
        }
        let giveAnswer = true // т.к. кнопка да
        viewController?.showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer) // проверяем правильность ответа
    }
}

