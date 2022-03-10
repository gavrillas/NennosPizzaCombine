//
//  DrinkObject+CoreDataClass.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 18..
//
//

import CoreData
import Foundation

@objc(DrinkObject)
public class DrinkObject: NSManagedObject {}

extension DrinkObject: Domainable {
    func toDomainModel() -> Drink {
        return Drink(price: price,
                     name: name ?? "",
                     id: Int(id))
    }

    func fromDomainModel(domainModel: Drink) {
        price = domainModel.price
        name = domainModel.name
        id = Int64(domainModel.id)
    }
}
