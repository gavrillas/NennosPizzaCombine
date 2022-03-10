//
//  Coordinator.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 07..
//

import Foundation
import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }

    func start()

    func showPizzaDetails(viewModel: PizzaDetailsViewModel)
    func showCart()
    func showDrinks()
}

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    deinit {
        print("coordinator DEINIT")
    }

    func start() {
        let viewController = StoryboardScene.Main.homeViewController.instantiate()
        navigationController.pushViewController(viewController, animated: true)
    }

    func showPizzaDetails(viewModel: PizzaDetailsViewModel) {
        let viewController = StoryboardScene.Main.pizzaDetailsViewController.instantiate()
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
    }

    func showCart() {
        let viewController = StoryboardScene.Main.cartViewController.instantiate()
        navigationController.pushViewController(viewController, animated: true)
    }

    func showDrinks() {
        let viewController = StoryboardScene.Main.drinksViewController.instantiate()
        navigationController.pushViewController(viewController, animated: true)
    }
}
