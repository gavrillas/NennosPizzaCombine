
import Combine
import Foundation

enum PizzaServiceError: Error, LocalizedError {
    case badUrl(url: String)
    case parsing(description: String)
    case network(description: String)
    case unkown(description: String)

    var localizedDescription: String {
        switch self {
        case let .badUrl(url):
            return "This string can not be converted to URL: \(url)"
        case let .parsing(description):
            return "Couldn't parse the response from server\n \(description)"
        case let .network(description):
            return "Request to API Server failed\n \(description)"
        case let .unkown(description):
            return "An unkown error occurred\n \(description)"
        }
    }
}

protocol PizzaServiceUseCase {
    func getPizzas() -> AnyPublisher<PizzaResponse, PizzaServiceError>
    func getIngridients() -> AnyPublisher<[Ingredient], PizzaServiceError>
    func getDrinks() -> AnyPublisher<[Drink], PizzaServiceError>
}
