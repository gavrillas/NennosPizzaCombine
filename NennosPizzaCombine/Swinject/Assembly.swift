//
//  Assembly.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 05..
//

import Foundation
import Swinject
import UIKit

class CoordinatorAssembly: Assembly {
    func assemble(container: Container) {
        let navigationController = UINavigationController()
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ColorAsset.Color.red]
        navigationController.navigationBar.tintColor = Asset.Color.red.color
        navigationController.navigationBar.backgroundColor = .white

        container.register(Coordinator.self) { _ in
            AppCoordinator(navigationController: navigationController)
        }.inObjectScope(.container)
    }
}

class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PizzaRepositoryUseCase.self) { _ in
            PizzaRepository(context: AppDelegate.managedContext)
        }

        container.register(DrinkRepositoryUseCase.self) { _ in
            DrinkRepository(context: AppDelegate.managedContext)
        }
    }
}

class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PizzaServiceUseCase.self) { _ in
            PizzaService()
        }

        container.register(CartServiceUseCase.self) { r in
            CartService(pizzaRepository: r.resolve(PizzaRepositoryUseCase.self)!,
                        drinkRepository: r.resolve(DrinkRepositoryUseCase.self)!)
        }.inObjectScope(.container)
    }
}

class ViewModelAssembly: Assembly {
    func assemble(container: Container) {
        container.register(HomeViewModelProtocol.self) { r in
            HomeViewModel(pizzaService: r.resolve(PizzaServiceUseCase.self)!,
                          cartService: r.resolve(CartServiceUseCase.self)!)
        }

        container.register(CartViewModelProtocol.self) { r in
            CartViewModel(pizzaService: r.resolve(PizzaServiceUseCase.self)!,
                          cartService: r.resolve(CartServiceUseCase.self)!)
        }

        container.register(DrinksViewModelProtocol.self) { r in
            DrinksViewModel(pizzaService: r.resolve(PizzaServiceUseCase.self)!,
                            cartService: r.resolve(CartServiceUseCase.self)!)
        }
    }
}
