import Combine
import Foundation

struct PizzaCellViewModel {
    let name: String
    let ingredients: String
    let imageUrl: String?
    let priceText: String
    let addToCart = PassthroughSubject<Void, Never>()

    private var subscriptions = Set<AnyCancellable>()

    init(basePrice: Int, pizza: Pizza, ingredients: [Ingredient], cartService: CartServiceUseCase) {
        name = pizza.name
        imageUrl = pizza.imageURL

        let pizzaIngredients = ingredients
            .filter { pizza.ingredients.contains($0.id) }

        self.ingredients = pizzaIngredients
            .map { $0.name }
            .joined(separator: ", ")

        let price = pizzaIngredients
            .map { $0.price }
            .reduce(Double(basePrice)) { $0 + $1 }

        priceText = Txt.Price.currency(price)

        addToCart.sink(receiveValue: {
            cartService.addToCart(pizza: pizza)
        }).store(in: &subscriptions)
    }
}
