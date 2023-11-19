import UIKit

// вью модель для состояния "Вопрос показан"
struct QuizStepViewModel {
    // картинка с афишей фильма с типом UIImage
    let image: UIImage
    // вопрос о рейтинге квиза
    let question: String
    // порядковый номер этого вопроса (ex. "1/10")
    let questionNumber: String
}
