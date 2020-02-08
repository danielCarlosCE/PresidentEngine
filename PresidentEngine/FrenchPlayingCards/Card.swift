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
    
    enum Rank: Int, CaseIterable {
        case aces = 1
        case two, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king
    }
    
    enum Suit: String, CaseIterable {
        case spades   = "♠︎"
        case hearts   = "♥︎"
        case diamonds = "♦︎"
        case clubs    = "♣︎"
    }
}

extension Card: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rank)
        hasher.combine(suit)
    }
}
