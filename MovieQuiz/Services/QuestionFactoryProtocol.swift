import Foundation

protocol QuestionFactoryProtocol {    
    // свойство с делегатом
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
}
