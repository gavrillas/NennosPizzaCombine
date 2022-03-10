//
//  IngredientCellViewModel.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 07..
//

import Combine

struct IngredientCellViewModel: ItemCellViewModel {
    let titleText: String
    let priceText: String
    let isImageHidden: Bool

    let buttonTap = PassthroughSubject<Void, Never>()

    init(ingredient: Ingredient, pizzaIngredients: [Int]) {
        titleText = ingredient.name
        priceText = Txt.Price.currency(ingredient.price)
        isImageHidden = !pizzaIngredients.contains(ingredient.id)
    }
}
