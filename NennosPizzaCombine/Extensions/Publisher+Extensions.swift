//
//  Publisher+Extensions.swift
//  NennosPizzaCombine
//
//  Created by kristof on 2021. 11. 05..
//

import Combine
import Foundation

extension Publisher {
    func shareReplay(capacity: Int = .max) -> Publishers.ShareReplay<Self> {
        return Publishers.ShareReplay(upstream: self, capacity: capacity)
    }

    func withLatestFrom<Other: Publisher, Result>(_ other: Other,
                                                  resultSelector: @escaping (Output, Other.Output) -> Result)
        -> Publishers.WithLatestFrom<Self, Other, Result>
    {
        return .init(upstream: self, second: other, resultSelector: resultSelector)
    }

    func withLatestFrom<Other: Publisher>(_ other: Other)
        -> Publishers.WithLatestFrom<Self, Other, Other.Output>
    {
        return .init(upstream: self, second: other) { $1 }
    }
}
