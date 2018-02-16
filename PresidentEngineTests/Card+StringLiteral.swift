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
        self.suit = .clubs

        switch value {
        case "A", "a":
            self.rank = .aces
        case "2":
            self.rank = .two
        case "3":
            self.rank = .three
        case "4":
            self.rank = .four
        case "5":
            self.rank = .five
        case "6":
            self.rank = .six
        case "7":
            self.rank = .seven
        case "8":
            self.rank = .eight
        case "9":
            self.rank = .nine
        case "10":
            self.rank = .ten
        case "J", "j":
            self.rank = .jack
        case "Q", "q":
            self.rank = .queen
        case "K", "k":
            self.rank = .king

        default:
            fatalError("Unkown value for creating card: \(value)")
        }
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
