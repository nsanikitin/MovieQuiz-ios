import UIKit

struct AlertModel {
    let title: String // заголовк алерта
    let message: String // текст сообщения алерта
    let buttonText: String // текст кнопки алерта
    var completion: (() -> Void) // замыкание действия кнопки алерта
}
