//
//  DrinkRepository.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 19..
//

import CoreData
import Foundation

protocol DrinkRepositoryUseCase {
    @discardableResult func getDrinks(predicate: NSPredicate?) -> Result<[Drink], Error>
    @discardableResult func create(drink: Drink) -> Result<Bool, Error>
    @discardableResult func delete(drink: Drink) -> Result<Bool, Error>
    @discardableResult func deleteAll() -> Result<Bool, Error>
    @discardableResult func saveChanges() -> Result<Bool, Error>
}

struct DrinkRepository: DrinkRepositoryUseCase {
    private let repository: CoreDataRepository<DrinkObject>

    init(context: NSManagedObjectContext) {
        repository = CoreDataRepository<DrinkObject>(managedObjectContext: context)
    }

    @discardableResult func getDrinks(predicate: NSPredicate?) -> Result<[Drink], Error> {
        let result = repository.get(predicate: predicate, sortDescriptors: [.init(key: "name", ascending: true)])
        switch result {
        case let .success(drinkObjects):
            let drinks = drinkObjects.map { drinkObject -> Drink in
                drinkObject.toDomainModel()
            }

            return .success(drinks)
        case let .failure(error):
            return .failure(error)
        }
    }

    @discardableResult func create(drink: Drink) -> Result<Bool, Error> {
        let result = repository.create()
        switch result {
        case let .success(drinkObject):
            drinkObject.fromDomainModel(domainModel: drink)
            return .success(true)

        case let .failure(error):
            return .failure(error)
        }
    }

    func delete(drink: Drink) -> Result<Bool, Error> {
        let result = repository.get(predicate: NSPredicate(format: "id = \(drink.id)"), sortDescriptors: nil)
        switch result {
        case let .success(drinks):
            guard let drink = drinks.first else { return .success(false) }
            return repository.delete(entity: drink)
        case let .failure(error):
            return .failure(error)
        }
    }

    @discardableResult func deleteAll() -> Result<Bool, Error> {
        repository.deleteAll()
    }

    @discardableResult func saveChanges() -> Result<Bool, Error> {
        repository.saveChanges()
    }
}
