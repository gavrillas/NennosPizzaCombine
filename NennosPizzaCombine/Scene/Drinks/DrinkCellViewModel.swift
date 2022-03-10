//
//  DrinkCellViewModel.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 14..
//

import Combine
import Foundation

struct DrinkCellViewModel: ItemCellViewModel {
    var isImageHidden: Bool
    var titleText: String
    var priceText: String

    let buttonTap = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()

    init(drink: Drink, cartService: CartServiceUseCase) {
        isImageHidden = false
        titleText = drink.name
        priceText = Txt.Price.currency(drink.price)

        buttonTap.sink(receiveValue: {
            cartService.addToCart(drink: drink)
        }).store(in: &subscriptions)
    }
}
