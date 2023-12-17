import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    // вычисляемое свойство, чтобы получить ссылку с картиной в желаемом качестве
    var resizedImageURL: URL {
        let urlString = imageURL.absoluteString // создаем строку из адреса
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg" //  обрезаем лишнюю часть и добавляем модификатор желаемого качества
        
        // пытаемся создать новый адрес, если не получается возвращаем старый
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        
        return newURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
