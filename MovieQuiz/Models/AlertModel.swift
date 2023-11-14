import UIKit

// струкутура для алерта
struct AlertModel {
    // текст заголовка алерта
    let title: String
    // текст сообщения алерта
    let message: String
    // текст для кнопки алерта
    let buttonText: String
    // замыкание без параметров для действия по кнопке алерта
//    var completion = UIAlertAction() { [weak self] _ in // слабая ссылка на self
//        guard let self = self else { return } // разворачиваем слабую ссылку
//        self.currentQuestionIndex = 0 // обнуляем текущий индекс вопроса в массиве
//        self.correctAnswers = 0 // обнуляем кол-во правильных ответов
//        
//        // сбрасываем до первого вопроса и показываем его
//        questionFactory?.requestNextQuestion()
//    }
}
