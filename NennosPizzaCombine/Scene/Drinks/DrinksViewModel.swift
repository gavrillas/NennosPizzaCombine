//
//  DrinksViewModel.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 13..
//

import Combine
import Foundation

protocol DrinksViewModelProtocol {
    var tableData: AnyPublisher<[ItemCellViewModel], PizzaServiceError> { get }
}

struct DrinksViewModel: DrinksViewModelProtocol {
    private let pizzaService: PizzaServiceUseCase
    private let cartService: CartServiceUseCase
    let tableData: AnyPublisher<[ItemCellViewModel], PizzaServiceError>

    init(pizzaService: PizzaServiceUseCase, cartService: CartServiceUseCase) {
        self.pizzaService = pizzaService
        self.cartService = cartService

        tableData = pizzaService.getDrinks().map { drinks in
            drinks.map { DrinkCellViewModel(drink: $0, cartService: cartService) }
        }.eraseToAnyPublisher()
    }
}
