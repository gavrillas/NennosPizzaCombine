import Combine
import Foundation

struct PizzaService: PizzaServiceUseCase {
    func getPizzas() -> AnyPublisher<PizzaResponse, PizzaServiceError> {
        request(.pizzas)
    }

    func getIngridients() -> AnyPublisher<[Ingredient], PizzaServiceError> {
        request(.ingridients)
    }

    func getDrinks() -> AnyPublisher<[Drink], PizzaServiceError> {
        request(.drinks)
    }

    private func request<T: Decodable>(_ route: PizzaServiceRouter) -> AnyPublisher<T, PizzaServiceError> {
        do {
            let urlRequest = try route.asURLRequest()
            return request(urlRequest)
        } catch {
            if let error = error as? PizzaServiceError {
                return Fail(error: error).eraseToAnyPublisher()
            } else {
                return Fail(error: PizzaServiceError.unkown(description: error.localizedDescription))
                    .eraseToAnyPublisher()
            }
        }
    }

    private func request<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, PizzaServiceError> {
        let publisher = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> PizzaServiceError in
                switch error {
                case is URLError:
                    return .network(description: error.localizedDescription)
                case is DecodingError:
                    return .parsing(description: error.localizedDescription)
                default:
                    return .unkown(description: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()

        return publisher
    }
}

extension PizzaService {
    enum PizzaServiceRouter {
        case pizzas
        case ingridients
        case drinks
        case checkout(cart: Cart)

        enum HTTPMethod: String {
            case get = "GET"
            case post = "POST"
        }

        func asURLRequest() throws -> URLRequest {
            guard let url = URL(string: baseUrl) else { throw PizzaServiceError.badUrl(url: baseUrl) }

            var urlRequest = URLRequest(url: url.appendingPathComponent(path))

            urlRequest.httpMethod = method

            if let httpBody = body {
                urlRequest.httpBody = httpBody
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            return urlRequest
        }

        private var baseUrl: String {
            switch self {
            case .pizzas, .ingridients, .drinks:
                return "https://doclerlabs.github.io/mobile-native-challenge"
            case .checkout:
                return "http://httpbin.org"
            }
        }

        private var method: String {
            switch self {
            case .pizzas, .drinks, .ingridients:
                return HTTPMethod.get.rawValue
            case .checkout:
                return HTTPMethod.post.rawValue
            }
        }

        private var path: String {
            switch self {
            case .pizzas:
                return "/pizzas.json"
            case .ingridients:
                return "/ingredients.json"
            case .drinks:
                return "/drinks.json"
            case .checkout:
                return "/post"
            }
        }

        private var body: Data? {
            switch self {
            case let .checkout(cart):
                do {
                    return try JSONSerialization.data(withJSONObject: cart)
                } catch { return nil }
            default:
                return nil
            }
        }
    }
}
