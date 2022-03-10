//
//  ShareReplaySubscription.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 05..
//

import Combine
import Foundation

private final class ShareReplaySubscription<Output, Failure: Error>: Subscription {
    // 2
    let capacity: Int
    // 3
    var subscriber: AnySubscriber<Output, Failure>?
    // 4
    var demand: Subscribers.Demand = .none
    // 5
    var buffer: [Output]
    // 6
    var completion: Subscribers.Completion<Failure>?

    init<S>(subscriber: S,
            replay: [Output],
            capacity: Int,
            completion: Subscribers.Completion<Failure>?)
        where S: Subscriber,
        Failure == S.Failure,
        Output == S.Input
    {
        // 7
        self.subscriber = AnySubscriber(subscriber)
        // 8
        buffer = replay
        self.capacity = capacity
        self.completion = completion
    }

    private func complete(with completion: Subscribers.Completion<Failure>) {
        // 9
        guard let subscriber = subscriber else { return }
        self.subscriber = nil
        // 10
        self.completion = nil
        buffer.removeAll()
        // 11
        subscriber.receive(completion: completion)
    }

    private func emitAsNeeded() {
        guard let subscriber = subscriber else { return }
        // 12
        while demand > .none, !buffer.isEmpty {
            // 13
            demand -= .max(1)
            // 14
            let nextDemand = subscriber.receive(buffer.removeFirst())
            // 15
            if nextDemand != .none {
                demand += nextDemand
            }
        }
        // 16
        if let completion = completion {
            complete(with: completion)
        }
    }

    func request(_ demand: Subscribers.Demand) {
        if demand != .none {
            self.demand += demand
        }
        emitAsNeeded()
    }

    func receive(_ input: Output) {
        guard subscriber != nil else { return }
        // 17
        buffer.append(input)
        if buffer.count > capacity {
            // 18
            buffer.removeFirst()
        }
        // 19
        emitAsNeeded()
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        guard let subscriber = subscriber else { return }
        self.subscriber = nil
        buffer.removeAll()
        subscriber.receive(completion: completion)
    }

    func cancel() {
        complete(with: .finished)
    }
}

extension Publishers {
    // 20
    final class ShareReplay<Upstream: Publisher>: Publisher {
        // 21
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure

        // 22
        private let lock = NSRecursiveLock()
        // 23
        private let upstream: Upstream
        // 24
        private let capacity: Int
        // 25
        private var replay = [Output]()
        // 26
        private var subscriptions = [ShareReplaySubscription<Output, Failure>]()
        // 27
        private var completion: Subscribers.Completion<Failure>?

        init(upstream: Upstream, capacity: Int) {
            self.upstream = upstream
            self.capacity = capacity
        }

        func receive<S: Subscriber>(subscriber: S)
            where Failure == S.Failure,
            Output == S.Input
        {
            lock.lock()
            defer { lock.unlock() }

            // 34
            let subscription = ShareReplaySubscription(
                subscriber: subscriber,
                replay: replay,
                capacity: capacity,
                completion: completion
            )

            // 35
            subscriptions.append(subscription)
            // 36
            subscriber.receive(subscription: subscription)

            // 37
            guard subscriptions.count == 1 else { return }
            // 38
            let sink = AnySubscriber(
                // 39
                receiveSubscription: { subscription in
                    // 40
                    subscription.request(.unlimited)
                },
                receiveValue: { [weak self] (value: Output) -> Subscribers.Demand in
                    self?.relay(value)
                    return .none
                },
                receiveCompletion: { [weak self] in
                    self?.complete($0)
                }
            )

            upstream.subscribe(sink)
        }

        private func relay(_ value: Output) {
            // 28
            lock.lock()
            defer { lock.unlock() }

            // 29
            guard completion == nil else { return }

            // 30
            replay.append(value)
            if replay.count > capacity {
                replay.removeFirst()
            }
            // 31
            subscriptions.forEach {
                $0.receive(value)
            }
        }

        private func complete(_ completion: Subscribers.Completion<Failure>) {
            lock.lock()
            defer { lock.unlock() }
            // 32
            self.completion = completion
            // 33
            subscriptions.forEach {
                $0.receive(completion: completion)
            }
        }
    }
}
