//
//  Card+StringLiteral.swift
//  PresidentEngineTests
//
//  Created by HE:labs on 15/02/18.
//  Copyright © 2018 danielcarlosce. All rights reserved.
//

@testable import PresidentEngine

extension Card: ExpressibleByStringLiteral {
    public init(stringLiteral value: String)  {
        self.init(value: value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(value: value)
    }

    public init(extendedGraphemeClusterLiteral value: String)  {
        self.init(value: value)
    }

    private init(value: String) {
        //suit doesn't matter here
        let value = value.removingSuit()
        let suit = Suit.clubs
        var rank = Rank.aces

        switch value {
        case "A", "a":
            rank = .aces
        case "2":
            rank = .two
        case "3":
            rank = .three
        case "4":
            rank = .four
        case "5":
            rank = .five
        case "6":
            rank = .six
        case "7":
            rank = .seven
        case "8":
            rank = .eight
        case "9":
            rank = .nine
        case "10":
            rank = .ten
        case "J", "j":
            rank = .jack
        case "Q", "q":
            rank = .queen
        case "K", "k":
            rank = .king
            
        default:
            fatalError("Unkown value for creating card: \(value)")
        }
        
        self.init(rank: rank, suit: suit)
    }

}

fileprivate extension String {
    func removingSuit() -> String {
        return replacingOccurrences(of: "♠︎", with: "")
              .replacingOccurrences(of: "♥︎", with: "")
              .replacingOccurrences(of: "♦︎", with: "")
              .replacingOccurrences(of: "♣︎", with: "")
    }
}
