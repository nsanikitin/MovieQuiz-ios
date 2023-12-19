import UIKit

final class AlertPresenter {
    weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController?) {
        self.viewController = viewController
    }

    // показ алерта с результатами раунда квиза
    func showAlert(alertModel: AlertModel) {
        
        // параметры для алерта
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Alert" // присваем алерту id
        
        // настройка параметров по нажатию кнопки алерта
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in 
            alertModel.completion()
        }
        
        alert.addAction(action)
        
        viewController?.present(alert, animated: true)
    }
}
