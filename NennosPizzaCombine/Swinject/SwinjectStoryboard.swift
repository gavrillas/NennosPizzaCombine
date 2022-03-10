//
//  SwinjectStoryboard.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 19..
//

import Foundation
import SwinjectStoryboard

extension SwinjectStoryboard {
    @objc class func setup() {
        let container = DependencyProvider.shared.container

        defaultContainer.storyboardInitCompleted(HomeViewController.self) { _, controller in
            controller.viewModel = container.resolve(HomeViewModelProtocol.self)
            controller.coordinator = container.resolve(Coordinator.self)
        }

        defaultContainer.storyboardInitCompleted(PizzaDetailsViewController.self) { _, _ in
        }

        defaultContainer.storyboardInitCompleted(CartViewController.self) { _, controller in
            controller.coordinator = container.resolve(Coordinator.self)
            controller.viewModel = container.resolve(CartViewModelProtocol.self)
        }

        defaultContainer.storyboardInitCompleted(DrinksViewController.self) { _, controller in
            controller.viewModel = container.resolve(DrinksViewModelProtocol.self)
        }
    }
}
