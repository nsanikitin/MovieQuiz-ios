import Foundation

/// отвечает за загрузку данных по URL
struct NetworkClient: NetworkRouting {

    // реализация протокола Error на случай ошибки
    private enum NetworkError: Error {
        case codeError
    }
    
    // метод загрузки данных по заданному URL
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
}
