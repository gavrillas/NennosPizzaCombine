//
//  PizzaDetailsViewModel.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 05..
//

import Combine
import Foundation

protocol SectionModelType {
    var items: [SectionItemType] { get }
}

protocol SectionItemType {}

protocol PizzaDetailsViewModelProtocol {
    var tableData: AnyPublisher<[SectionModelType], Never> { get }
    var totalPrice: AnyPublisher<String, Never> { get }
    var selectedIndex: PassthroughSubject<IndexPath, Never> { get }
    var pizzaSubject: CurrentValueSubject<Pizza, Never> { get }
    var newPizzaPublisher: AnyPublisher<Pizza, Never> { get }
    var addToCart: PassthroughSubject<Void, Never> { get }
    var addedToCart: AnyPublisher<Void, Never> { get }
    var title: Just<String?> { get }
}

struct PizzaDetailsViewModel: PizzaDetailsViewModelProtocol {
    struct SectionModel: SectionModelType {
        var items: [SectionItemType]
    }

    enum SectionItem: SectionItemType {
        case image(imageUrl: String?)
        case ingredient(viewModel: ItemCellViewModel)
    }

    let tableData: AnyPublisher<[SectionModelType], Never>
    let totalPrice: AnyPublisher<String, Never>
    let selectedIndex = PassthroughSubject<IndexPath, Never>()
    let pizzaSubject: CurrentValueSubject<Pizza, Never>
    let newPizzaPublisher: AnyPublisher<Pizza, Never>
    let addToCart = PassthroughSubject<Void, Never>()
    let addedToCart: AnyPublisher<Void, Never>
    let title: Just<String?>

    init(pizza: Pizza, ingredients: [Ingredient], basePrice: Int, cartService: CartServiceUseCase) {
        pizzaSubject = CurrentValueSubject<Pizza, Never>(pizza)
        title = Just(pizza.name.uppercased())

        newPizzaPublisher = selectedIndex.withLatestFrom(pizzaSubject) { indexPath, pizza -> Pizza in

            let ingredientId = ingredients[indexPath.row].id
            var pizzaIngredients = pizza.ingredients
            if pizzaIngredients.contains(ingredientId) {
                pizzaIngredients.removeAll { $0 == ingredientId }
            } else {
                pizzaIngredients.append(ingredientId)
            }
            return Pizza(ingredients: pizzaIngredients, name: pizza.name, imageURL: pizza.imageURL)
        }.eraseToAnyPublisher()

        tableData = pizzaSubject
            .map { pizza in
                var sectionModels = [SectionModel(items: [SectionItem.image(imageUrl: pizza.imageURL)])]

                let ingredientSectionItems = ingredients.map { ingredient in
                    SectionItem.ingredient(viewModel: IngredientCellViewModel(ingredient: ingredient,
                                                                              pizzaIngredients: pizza.ingredients))
                }

                sectionModels.append(SectionModel(items: ingredientSectionItems))
                return sectionModels
            }.eraseToAnyPublisher()

        totalPrice = pizzaSubject.map { pizza in
            ingredients.filter { pizza.ingredients.contains($0.id) }
                .map { $0.price }
                .reduce(Double(basePrice)) { $0 + $1 }
        }.map { Txt.PizzaDetails.addToCart($0) }
            .eraseToAnyPublisher()

        addedToCart = addToCart.withLatestFrom(pizzaSubject) { _, pizza in
            cartService.addToCart(pizza: pizza)
        }.eraseToAnyPublisher()
    }
}
