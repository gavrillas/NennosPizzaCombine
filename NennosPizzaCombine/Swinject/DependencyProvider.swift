//
//  DependencyProvider.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 19..
//

import Swinject

class DependencyProvider {
    let container = Container()
    private let assembler: Assembler

    static let shared = DependencyProvider()

    private init() {
        assembler = Assembler(
            [
                CoordinatorAssembly(),
                RepositoryAssembly(),
                ServiceAssembly(),
                ViewModelAssembly(),
            ],
            container: container
        )
    }
}
