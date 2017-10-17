//
//  Deck.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 10/16/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import Foundation

struct Deck {
    private let cards: [Card]
    
    init(numberOfPackets: Int) {
        var packets: [CardsPacket] = []
        
        let packet = CardsPacket()
        for _ in 0..<numberOfPackets {
            packets.append(packet)
        }
        
        self.cards = packets.flatMap { $0.cards }
    }
    
    func shuffled() -> [Card] {
        var cards = self.cards
        var shuffledCards: [Card] = []
        
        while cards.count > 0 {
            let numberCards = UInt32(cards.count)
            let randomIndex = Int(arc4random_uniform(numberCards))
            let selectedCard = cards.remove(at: randomIndex)
            
            shuffledCards.append(selectedCard)
        }
        
        return shuffledCards
    }
}
