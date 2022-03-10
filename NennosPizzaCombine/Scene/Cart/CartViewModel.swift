//
//  CartViewModel.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 12..
//

import Combine
import Foundation

protocol CartViewModelProtocol {
    var tableData: AnyPublisher<[ItemCellViewModel], Never> { get }
    var selectedIndex: PassthroughSubject<IndexPath, Never> { get }
}

struct CartViewModel: CartViewModelProtocol {
    private let pizzaService: PizzaServiceUseCase
    private let cartService: CartServiceUseCase
    let tableData: AnyPublisher<[ItemCellViewModel], Never>
    let selectedIndex = PassthroughSubject<IndexPath, Never>()

    init(pizzaService: PizzaServiceUseCase, cartService: CartServiceUseCase) {
        self.pizzaService = pizzaService
        self.cartService = cartService

        let basePrice = pizzaService.getPizzas()
            .map { $0.basePrice }
            .replaceError(with: 0)
            .shareReplay(capacity: 1)

        tableData = pizzaService.getIngridients()
            .replaceError(with: [])
            .combineLatest(basePrice, cartService.cartDataChanged)
            .map { ingredients, basePrice, _ -> [CartItemCellViewModel] in
                let pizzas = cartService.getPizzas()
                let drinks = cartService.getDrinks()

                let pizzaViewModels = pizzas.map { pizza in
                    CartItemCellViewModel(pizza: pizza, ingredients: ingredients, basePrice: basePrice, cartService: cartService)
                }

                let drinkViewModels = drinks.map { drink in
                    CartItemCellViewModel(drink: drink, cartService: cartService)
                }

                return pizzaViewModels + drinkViewModels
            }.eraseToAnyPublisher()
    }
}
