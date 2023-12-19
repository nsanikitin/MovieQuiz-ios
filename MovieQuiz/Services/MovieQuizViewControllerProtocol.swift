import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResult(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    
    func showLoadIndicator()
    func hideLoadIndicator()
    
    func turnOnButtons()
    func turnOffButtons() 
    
    func showNetworkError(message: String)
    func showDataError(message: String)
}
