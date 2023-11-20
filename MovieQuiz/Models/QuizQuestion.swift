import Foundation

// структура для вопросов
struct QuizQuestion {
    // название фильма, совпадает с названием картинки афиши фильма в Assets
    let image: String
    // вопрос о рейтинге фильма
    let text: String
    // правильный ответ на вопрос
    let correctAnswer: Bool
}
