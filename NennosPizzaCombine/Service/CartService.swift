//
//  CartService.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 19..
//

import Combine
import Foundation

protocol CartServiceUseCase {
    func addToCart(pizza: Pizza)
    func addToCart(drink: Drink)
    func removeFromCart(pizza: Pizza)
    func removeFromCart(drink: Drink)
    func emptyCart()
    func getPizzas() -> [Pizza]
    func getDrinks() -> [Drink]

    var cartDataChanged: CurrentValueSubject<Void, Never> { get }
}

struct CartService: CartServiceUseCase {
    private let pizzaRepository: PizzaRepositoryUseCase
    private let drinkRepository: DrinkRepositoryUseCase

    let cartDataChanged = CurrentValueSubject<Void, Never>(())

    init(pizzaRepository: PizzaRepositoryUseCase, drinkRepository: DrinkRepositoryUseCase) {
        self.pizzaRepository = pizzaRepository
        self.drinkRepository = drinkRepository
    }

    func addToCart(pizza: Pizza) {
        pizzaRepository.create(pizza: pizza)
        let result = pizzaRepository.saveChanges()
        print(result)
        cartDataChanged.send()
    }

    func addToCart(drink: Drink) {
        drinkRepository.create(drink: drink)
        drinkRepository.saveChanges()
        cartDataChanged.send()
    }

    func removeFromCart(pizza: Pizza) {
        pizzaRepository.delete(pizza: pizza)
        pizzaRepository.saveChanges()
        cartDataChanged.send()
    }

    func removeFromCart(drink: Drink) {
        drinkRepository.delete(drink: drink)
        drinkRepository.saveChanges()
        cartDataChanged.send()
    }

    func emptyCart() {
        pizzaRepository.deleteAll()
        drinkRepository.deleteAll()
        pizzaRepository.saveChanges()
        drinkRepository.saveChanges()
        cartDataChanged.send()
    }

    func getPizzas() -> [Pizza] {
        let result = pizzaRepository.getPizzas(predicate: nil)
        switch result {
        case let .success(pizzas):
            return pizzas
        case .failure:
            return []
        }
    }

    func getDrinks() -> [Drink] {
        let result = drinkRepository.getDrinks(predicate: nil)
        switch result {
        case let .success(drinks):
            return drinks
        case .failure:
            return []
        }
    }
}
