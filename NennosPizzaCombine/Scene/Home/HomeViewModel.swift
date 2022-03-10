import Combine
import Foundation

protocol HomeViewModelProtocol {
    var tableData: AnyPublisher<[PizzaCellViewModel], PizzaServiceError> { get }
    var selectedPizza: AnyPublisher<PizzaDetailsViewModel, PizzaServiceError> { get }
    var selectedIndex: PassthroughSubject<IndexPath, PizzaServiceError> { get }
    var customPizzaSubject: PassthroughSubject<Void, Never> { get }
}

struct HomeViewModel: HomeViewModelProtocol {
    private let pizzaService: PizzaServiceUseCase
    private let cartService: CartServiceUseCase
    let tableData: AnyPublisher<[PizzaCellViewModel], PizzaServiceError>
    let selectedPizza: AnyPublisher<PizzaDetailsViewModel, PizzaServiceError>
    let selectedIndex = PassthroughSubject<IndexPath, PizzaServiceError>()
    let customPizzaSubject = PassthroughSubject<Void, Never>()

    init(pizzaService: PizzaServiceUseCase, cartService: CartServiceUseCase) {
        self.pizzaService = pizzaService
        self.cartService = cartService
        let ingredients = pizzaService.getIngridients().shareReplay(capacity: 1)
        let pizzaResponse = pizzaService.getPizzas().shareReplay(capacity: 1)

        tableData = Publishers.CombineLatest(pizzaResponse, ingredients)
            .map { pizzaResponse, ingredients -> [PizzaCellViewModel] in
                let viewModels = pizzaResponse.pizzas.map { pizza in
                    PizzaCellViewModel(basePrice: pizzaResponse.basePrice, pizza: pizza, ingredients: ingredients, cartService: cartService)
                }
                return viewModels
            }.eraseToAnyPublisher()

        let customPizzaViewModel = customPizzaSubject
            .setFailureType(to: PizzaServiceError.self)
            .combineLatest(pizzaResponse, ingredients)
            .map { _, pizzaResponse, ingredients -> PizzaDetailsViewModel in
                PizzaDetailsViewModel(pizza: .init(ingredients: [],
                                                   name: Txt.PizzaDetails.customPizza,
                                                   imageURL: nil),
                                      ingredients: ingredients,
                                      basePrice: pizzaResponse.basePrice,
                                      cartService: cartService)
            }.eraseToAnyPublisher()

        selectedPizza = selectedIndex.combineLatest(pizzaResponse, ingredients)
            .map { indexPath, pizzaResponse, ingredients in
                PizzaDetailsViewModel(pizza: pizzaResponse.pizzas[indexPath.row], ingredients: ingredients,
                                      basePrice: pizzaResponse.basePrice,
                                      cartService: cartService)
            }.eraseToAnyPublisher()
            .merge(with: customPizzaViewModel)
            .eraseToAnyPublisher()
    }
}
