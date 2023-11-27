import UIKit

struct AlertModel {
    // текст заголовка алерта
    let title: String
    // текст сообщения алерта
    let message: String
    // текст кнопки алерта
    let buttonText: String
    // замыкание для действия по кнопке алерта
    var completion: (() -> Void)
}
