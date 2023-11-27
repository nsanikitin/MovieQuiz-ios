import Foundation

struct GameRecord: Codable {
    // количество правильных ответов
    let correct: Int
    // количество вопросов квиза
    let total: Int
    // дата завершения раунда
    let date: Date
    
    //  метод, чтобы понять лучше ли игра предыдущего рекорда
    func isGameBetter(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}
