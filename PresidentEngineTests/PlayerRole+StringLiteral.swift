//
//  PlayerRole+StringLiteral.swift
//  PresidentEngineTests
//
//  Created by HE:labs on 15/02/18.
//  Copyright © 2018 danielcarlosce. All rights reserved.
//

@testable import PresidentEngine

//when the roles doesn't matter
extension Player: ExpressibleByStringLiteral {
    public init(stringLiteral value: String)  {
        self.init(value: value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(value: value)
    }

    private init(value: String) {
        self.init(name: value, role: .president)
    }
}

extension Role: ExpressibleByStringLiteral {
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
        switch value {
        case "president":
            self = .president
        case "vice-president":
            self = .vicePresident
        case "neutral":
            self = .neutral
        case "vice-scum":
            self = .viceScum
        case "scum":
            self = .scum

        default:
            fatalError("Unkown value for creating role: \(value)")
        }
    }
}
