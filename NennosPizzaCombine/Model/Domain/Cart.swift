//
//  Cart.swift
//  NennosPizza
//
//  Created by kristof on 2021. 10. 12..
//

struct Cart: Codable {
    var pizzas: [Pizza]
    var drinks: [Drink]

    init(pizzas: [Pizza], drinks: [Drink]) {
        self.pizzas = pizzas
        self.drinks = drinks
    }
}
