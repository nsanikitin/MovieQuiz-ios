import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // настройка для тестов: если один тест не прошёл, то следующие тесты запускаться не будут
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    // тест действий по нажатию кнопки да
    func testYesButton() {
        sleep(3)
        
        // Given
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        // When
        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её
        sleep(3)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"] // находим индекс вопроса
        
        // Then
        XCTAssertNotEqual(firstPosterData, secondPosterData) // проверяем, что постеры разные
        XCTAssertEqual(indexLabel.label, "2/10") // проверяем, что индекс изменился на 2
    }
    
    // тест действий по нажатию кнопки нет
    func testNoButton() {
        sleep(3)
        
        // Given
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        // When
        app.buttons["No"].tap() // находим кнопку `Нет` и нажимаем её
        sleep(3)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"] // находим индекс вопроса
        
        // Then
        XCTAssertNotEqual(firstPosterData, secondPosterData) // проверяем, что постеры разные
        XCTAssertEqual(indexLabel.label, "2/10") // проверяем, что индекс изменился на 2
    }
    
    // тест показа алерта после раунда
    func testAlertPresentAfterQuiz() {
        sleep(3)
        
        // Given
        for _ in 1...10 {
            app.buttons["Yes"].tap() // 10 раз нажимаем на кнопку 'Да', чтобы закончить раунд квиза
            sleep(2)
        }
        
        // When
        let quizAlert = app.alerts["Alert"] // находим алерт
        let quizAlertLabel = quizAlert.label // находим текст заголовка алерта
        let quizAlertButton = quizAlert.buttons.firstMatch.label // находим текст кнопки алерта
        
        // Then
        XCTAssertNotNil(quizAlert) // проверяем, что алерт существует
        XCTAssertEqual(quizAlertLabel, "Этот раунд окончен!") // проверяем, что заголовок алерта правильный
        XCTAssertEqual(quizAlertButton, "Сыграть ещё раз") // проверяем, что текст кнопки алерта правильный
    }
    
    // тест, что алерт пропадает по нажатию кнопки действия на нем
    func testAlertDismissAfterQuiz() {
        sleep(3)
        
        // Given
        for _ in 1...10 {
            app.buttons["No"].tap() // 10 раз нажимаем на кнопку 'Нет', чтобы закончить раунд квиза
            sleep(2)
        }
        
        // When
        let quizAlert = app.alerts["Alert"] // находим алерт
        quizAlert.buttons.firstMatch.tap() // нажимаем на кнопку алерта
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"] // находим индекс вопроса
        
        // Then
        XCTAssertFalse(quizAlert.exists) // проверяем, что алерт пропал
        XCTAssertEqual(indexLabel.label, "1/10") // проверяем что квиз начался заново
    }
}
