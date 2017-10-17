//
//  CardsPacket.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 10/16/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

struct CardsPacket {
    let cards: [Card]
    init() {
        let suits = Card.Suit.allValues
        let ranks = Card.Rank.allValues
        
        self.cards = ranks.flatMap { rank in
            suits.map { Card(rank: rank, suit: $0)}
        }
    }
}
