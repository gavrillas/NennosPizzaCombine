//
//  PizzaRepository.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 18..
//

import CoreData
import Foundation

protocol PizzaRepositoryUseCase {
    @discardableResult func getPizzas(predicate: NSPredicate?) -> Result<[Pizza], Error>
    @discardableResult func create(pizza: Pizza) -> Result<Bool, Error>
    @discardableResult func delete(pizza: Pizza) -> Result<Bool, Error>
    @discardableResult func deleteAll() -> Result<Bool, Error>
    @discardableResult func saveChanges() -> Result<Bool, Error>

    init(context: NSManagedObjectContext)
}

struct PizzaRepository: PizzaRepositoryUseCase {
    private let repository: CoreDataRepository<PizzaObject>

    init(context: NSManagedObjectContext) {
        repository = CoreDataRepository<PizzaObject>(managedObjectContext: context)
    }

    @discardableResult func getPizzas(predicate: NSPredicate?) -> Result<[Pizza], Error> {
        let result = repository.get(predicate: predicate, sortDescriptors: [.init(key: "name", ascending: true)])
        switch result {
        case let .success(pizzaObjects):

            let pizzas = pizzaObjects.map { pizzaObject -> Pizza in
                pizzaObject.toDomainModel()
            }

            return .success(pizzas)
        case let .failure(error):

            return .failure(error)
        }
    }

    @discardableResult func create(pizza: Pizza) -> Result<Bool, Error> {
        let result = repository.create()
        switch result {
        case let .success(pizzaObject):
            pizzaObject.fromDomainModel(domainModel: pizza)
            return .success(true)

        case let .failure(error):
            return .failure(error)
        }
    }

    @discardableResult func delete(pizza: Pizza) -> Result<Bool, Error> {
        let result = repository.get(predicate: NSPredicate(format: "ingredients == %@", pizza.ingredients), sortDescriptors: nil)
        switch result {
        case let .success(pizzas):
            guard let pizza = pizzas.first else { return .success(false) }
            return repository.delete(entity: pizza)
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
