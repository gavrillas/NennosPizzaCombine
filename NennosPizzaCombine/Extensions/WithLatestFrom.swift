import Combine

public extension Publishers {
    struct WithLatestFrom<Upstream: Publisher,
        Other: Publisher,
        Output>: Publisher where Upstream.Failure == Other.Failure
    {
        public typealias Failure = Upstream.Failure
        public typealias ResultSelector = (Upstream.Output, Other.Output) -> Output

        private let upstream: Upstream
        private let second: Other
        private let resultSelector: ResultSelector
        private var latestValue: Other.Output?

        init(upstream: Upstream,
             second: Other,
             resultSelector: @escaping ResultSelector)
        {
            self.upstream = upstream
            self.second = second
            self.resultSelector = resultSelector
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let sub = Subscription(upstream: upstream,
                                   second: second,
                                   resultSelector: resultSelector,
                                   subscriber: subscriber)
            subscriber.receive(subscription: sub)
        }
    }
}

// MARK: - Subscription

extension Publishers.WithLatestFrom {
    private class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private let subscriber: S
        private let resultSelector: ResultSelector
        private var latestValue: Other.Output?

        private let upstream: Upstream
        private let second: Other

        private var firstSubscription: Cancellable?
        private var secondSubscription: Cancellable?

        init(upstream: Upstream,
             second: Other,
             resultSelector: @escaping ResultSelector,
             subscriber: S)
        {
            self.upstream = upstream
            self.second = second
            self.subscriber = subscriber
            self.resultSelector = resultSelector
            trackLatestFromSecond()
        }

        func request(_: Subscribers.Demand) {
            firstSubscription = upstream
                .sink(
                    receiveCompletion: { [subscriber] in subscriber.receive(completion: $0) },
                    receiveValue: { [weak self] value in
                        guard let self = self else { return }

                        guard let latest = self.latestValue else { return }
                        _ = self.subscriber.receive(self.resultSelector(value, latest))
                    }
                )
        }

        private func trackLatestFromSecond() {
            let subscriber = AnySubscriber<Other.Output, Other.Failure>(
                receiveSubscription: { [weak self] subscription in
                    self?.secondSubscription = subscription
                    subscription.request(.unlimited)
                },
                receiveValue: { [weak self] value in
                    self?.latestValue = value
                    return .unlimited
                },
                receiveCompletion: nil
            )

            second.subscribe(subscriber)
        }

        func cancel() {
            firstSubscription?.cancel()
            secondSubscription?.cancel()
        }
    }
}
