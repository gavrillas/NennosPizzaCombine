//
//  CartItemCellViewModel.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 20..
//

import Combine
import Foundation

struct CartItemCellViewModel: ItemCellViewModel {
    let isImageHidden: Bool
    let titleText: String
    let priceText: String

    let buttonTap = PassthroughSubject<Void, Never>()

    private var subscriptions = Set<AnyCancellable>()

    init(drink: Drink, cartService: CartServiceUseCase) {
        isImageHidden = false
        titleText = drink.name
        priceText = Txt.Price.currency(drink.price)

        buttonTap.sink(receiveValue: {
            cartService.removeFromCart(drink: drink)
        }).store(in: &subscriptions)
    }

    init(pizza: Pizza, ingredients: [Ingredient], basePrice: Int, cartService: CartServiceUseCase) {
        isImageHidden = false
        titleText = pizza.name

        let price = ingredients.filter { pizza.ingredients.contains($0.id) }
            .map { $0.price }
            .reduce(Double(basePrice)) { $0 + $1 }

        priceText = Txt.Price.currency(price)

        buttonTap.sink(receiveValue: {
            cartService.removeFromCart(pizza: pizza)
        }).store(in: &subscriptions)
    }
}
