//
//  ToDomainModel.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 18..
//

protocol Domainable {
    associatedtype DomainModelType
    func toDomainModel() -> DomainModelType
    func fromDomainModel(domainModel: DomainModelType)
}
