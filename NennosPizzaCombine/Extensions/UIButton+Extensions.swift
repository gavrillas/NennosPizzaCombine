//
//  UIButton+Extensions.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 05..
//

import Combine
import UIKit

extension UIButton {
    var tap: AnyPublisher<Void, Never> {
        publisher(for: .touchUpInside)
            .eraseToAnyPublisher()
    }

    var titleText: String {
        get {
            title(for: .normal) ?? ""
        }
        set {
            setTitle(newValue, for: .normal)
        }
    }
}
