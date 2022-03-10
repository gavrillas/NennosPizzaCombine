//
//  PizzaResponse.swift
//  NennosPizza
//
//  Created by kristof on 2021. 10. 11..
//

import Foundation

struct PizzaResponse: Codable {
    let basePrice: Int
    let pizzas: [Pizza]
}
