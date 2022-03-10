//
//  Repository.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 18..
//

import CoreData
import Foundation

protocol Repository {
    associatedtype Entity

    func get(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error>

    func create() -> Result<Entity, Error>

    func delete(entity: Entity) -> Result<Bool, Error>

    func deleteAll() -> Result<Bool, Error>

    func saveChanges() -> Result<Bool, Error>
}

enum CoreDataError: Error {
    case invalidManagedObjectType
}

class CoreDataRepository<T: NSManagedObject>: Repository {
    typealias Entity = T

    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    func get(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error> {
        let fetchRequest = Entity.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            if let fetchResults = try managedObjectContext.fetch(fetchRequest) as? [Entity] {
                return .success(fetchResults)
            } else {
                return .failure(CoreDataError.invalidManagedObjectType)
            }
        } catch {
            return .failure(error)
        }
    }

    func create() -> Result<Entity, Error> {
        let className = String(describing: Entity.self)
        guard let managedObject = NSEntityDescription.insertNewObject(forEntityName: className, into: managedObjectContext) as? Entity else {
            return .failure(CoreDataError.invalidManagedObjectType)
        }
        return .success(managedObject)
    }

    func delete(entity: Entity) -> Result<Bool, Error> {
        managedObjectContext.delete(entity)
        return .success(true)
    }

    func deleteAll() -> Result<Bool, Error> {
        let result = get(predicate: nil, sortDescriptors: nil)
        switch result {
        case let .success(entities):
            var success = true
            var delitionError: Error?
            entities.forEach { entity in
                let delitionResult = delete(entity: entity)
                switch delitionResult {
                case let .success(successful):
                    success = successful ? success : !success
                case let .failure(error):
                    delitionError = error
                }
            }
            guard let error = delitionError else { return .success(success) }
            return .failure(error)
        case let .failure(error):
            return .failure(error)
        }
    }

    func saveChanges() -> Result<Bool, Error> {
        do {
            try managedObjectContext.save()
            return .success(true)
        } catch {
            managedObjectContext.rollback()
            return .failure(error)
        }
    }
}
