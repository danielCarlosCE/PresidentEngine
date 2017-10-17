//
//  Card.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 10/16/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

struct Card {
    let rank: Rank
    let suit: Suit
    enum Rank: Int {
        case aces = 1
        case two, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king
        
        static var allValues: [Rank] {
            return [.aces, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king]
        }
    }
    enum Suit: String {
        case spades   = "♠︎"
        case hearts   = "♥︎"
        case diamonds = "♦︎"
        case clubs    = "♣︎"
        
        static var allValues: [Suit] {
            return [.spades, .hearts, .diamonds, .clubs]
        }
    }
}
