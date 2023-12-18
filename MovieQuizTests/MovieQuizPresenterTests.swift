import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func show(quiz step: QuizStepViewModel) { }
    func showResult(quiz result: QuizResultsViewModel) { }
    
    func highlightImageBorder(isCorrect: Bool) { }
    
    func showLoadIndicator() { }
    func hideLoadIndicator() { }
    
    func turnOnButtons() { }
    func turnOffButtons() { }
    
    func showNetworkError(message: String) { }
    func showDataError(message: String) { }
    
}

final class MovieQuizPresenterTests: XCTestCase {
    // тест метода convert в MovieQuizPresenter
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
}
