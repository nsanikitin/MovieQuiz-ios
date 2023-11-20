import UIKit

final class AlertPresenter {
    weak var viewController: MovieQuizViewController? // ссылка на MovieQuizViewController

    // метод для показа результатов раунда квиза
    func showAlert(alertModel: AlertModel) {
        
        // задаем параметры для алерта
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        // настройка параметров по нажатию кнопки алерта
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in 
            alertModel.completion()
        }
        
        alert.addAction(action)
        
        viewController?.present(alert, animated: true)
    }
}
