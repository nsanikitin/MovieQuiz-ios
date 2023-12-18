import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Outlets
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Proprieties
    // статус бар в белый цвет
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadIndicator()
        configureImageBorder()
        
        alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Methods
    // конфигурация image согласно макету
    private func configureImageBorder() {
        imageView.layer.masksToBounds = true // разрешаем рисовать рамку
        imageView.layer.borderWidth = 8 // задаем ширину рамки согласно макету
        imageView.layer.cornerRadius = 20 // задаем скругление рамки согласно макету
    }
    
    // показ цвета рамки в соответствии с ответом
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // показ вопроса на экране
    func show(quiz step: QuizStepViewModel) {
        turnOnButtons() // включаем кнопки
        imageView.layer.borderColor = UIColor.clear.cgColor // убираем цвет рамки
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
    }
    
    // показ результата раунда квиза
    func showResult(quiz result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
        )
        
        alertPresenter?.showAlert(alertModel: alertModel) // показываем алерт с результами
    }
    
    // показ алерта при ошибке загрузки данных из сети
    func showNetworkError(message: String) {
        hideLoadIndicator()
        
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                showLoadIndicator()
                self.presenter.restartGame()
            }
        )
        
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    // показ алерта при ошибке загрузки данных изображения
    func showDataError(message: String) {
        hideLoadIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка в загрузке данных",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                showLoadIndicator()
                self.presenter.restartGame()
            }
        )
        
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    // показ индикатора загрузки
    func showLoadIndicator() {
        activityIndicator.startAnimating()
    }
    
    // скрытие индикатора загрузки
    func hideLoadIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // включение кнопок
    func turnOnButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    // выключение кнопок
    func turnOffButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    // MARK: - Actions
    // нажатие кнопки "нет"
    @IBAction private func noButtonDidTape(_ sender: Any) {
        presenter.noButtonDidTape()
    }
    
    // нажатие кнопки "да"
    @IBAction private func yesButtonDidTape(_ sender: Any) {
        presenter.yesButtonDidTape()
    }
    
}
