//
//  UIBarButtonItem+Extensions.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 09..
//

import Combine
import UIKit

private extension UIBarButtonItem {
    struct TapPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let barButtonItem: UIBarButtonItem

        public init(barButtonItem: UIBarButtonItem) {
            self.barButtonItem = barButtonItem
        }

        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            barButtonItem: barButtonItem)

            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - Subscription

extension UIBarButtonItem.TapPublisher {
    private final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Void {
        private var subscriber: S?
        private weak var barButtonItem: UIBarButtonItem?

        init(subscriber: S, barButtonItem: UIBarButtonItem) {
            self.subscriber = subscriber
            self.barButtonItem = barButtonItem

            barButtonItem.target = self
            barButtonItem.action = #selector(handleTap)
        }

        func request(_: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
            barButtonItem?.target = nil
            barButtonItem?.action = nil
        }

        @objc private func handleTap() {
            _ = subscriber?.receive()
        }
    }
}

extension UIBarButtonItem {
    var tapPublisher: AnyPublisher<Void, Never> {
        return TapPublisher(barButtonItem: self).eraseToAnyPublisher()
    }
}
