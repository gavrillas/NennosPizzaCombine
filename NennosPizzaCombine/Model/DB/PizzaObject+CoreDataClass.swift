//
//  PizzaObject+CoreDataClass.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 18..
//
//

import CoreData
import Foundation

@objc(PizzaObject)
public class PizzaObject: NSManagedObject {}

extension PizzaObject: Domainable {
    func toDomainModel() -> Pizza {
        return Pizza(ingredients: ingredients ?? [],
                     name: name ?? "",
                     imageURL: imageURL)
    }

    func fromDomainModel(domainModel: Pizza) {
        name = domainModel.name
        ingredients = domainModel.ingredients
        imageURL = domainModel.imageURL ?? ""
    }
}
