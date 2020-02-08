//
//  Play.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

enum Play {
    case go([Card])
    case skip
}

extension Play: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Card
    init(arrayLiteral elements: Card...) {
        guard !elements.isEmpty else {
            self = .skip
            return
        }
        self = .go(elements)
    }
}

extension Play: Hashable {
    static func ==(lhs: Play, rhs: Play) -> Bool {
        switch (lhs, rhs) {
        case (.skip, .skip): return true
        case (.go(let cardslhs), .go(let cardsrhs)):
            return cardslhs == cardsrhs
        default: return false
        }

    }
    func hash(into hasher: inout Hasher) {
        switch self {
        case .go(let cards):
            hasher.combine(cards)
        case .skip:
            hasher.combine(0)
        }
    }
}
