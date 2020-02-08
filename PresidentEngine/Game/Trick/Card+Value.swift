//
//  Card+Value.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

extension Card: Comparable {
    /**
     Gives each rank a number to serve as new rank.
     */
    var value: Int {
        switch self.rank {
        case .aces:
            return 14
        case .two:
            return 15
        default:
            return self.rank.rawValue
        }
    }
    
    public static func <(lhs: Card, rhs: Card) -> Bool {
        return lhs.value < rhs.value
    }
    
    public static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.value == rhs.value && lhs.rank == rhs.rank
    }
}
