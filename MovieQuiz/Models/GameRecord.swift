import Foundation

struct GameRecord: Codable {
    let correct: Int // количество правильных ответов
    let total: Int // количество вопросов квиза
    let date: Date // дата завершения раунда
    
    //  лучше ли игра предыдущего рекорда
    func isGameBetter(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}
