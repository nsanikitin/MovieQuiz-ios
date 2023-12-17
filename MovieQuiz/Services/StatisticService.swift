import Foundation

final class StatisticServiceImplementation: StatisticService {
    // ключи для всех сущностей
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    
    // кол-во верных ответов за все время
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    //  общее кол-во вопросов за все время
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    //  средняя точность в % за все время
    var totalAccuracy: Double {
        if total > 0 {
            return Double(correct) / Double(total) * 100
        } else {
            return 0
        }
    }
    
    // общее кол-во сыгранных квизов
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // лучшая игра
    var bestGame: GameRecord?  {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат лучшей игры")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    // сохранение статистики в UserDefaults
    func store(correct count: Int, total amount: Int) {
        self.correct += count // получаем общее кол-во правильных ответов за все время
        self.total += amount // получаем общее кол-во вопросов за все время
        self.gamesCount += 1 // увеличиваем кол-во сыгранных квизов
        
        let currentGame = GameRecord(correct: count, total: amount, date: Date()) // создаем текущую игру
        
        guard let anotherBestGame = bestGame else {
            return bestGame = currentGame
        }
        
        // проверяем лучше ли текущая игра уже записанной в UserDefaults
        if currentGame.isGameBetter(anotherBestGame) {
            bestGame = currentGame
        }
    }

}
