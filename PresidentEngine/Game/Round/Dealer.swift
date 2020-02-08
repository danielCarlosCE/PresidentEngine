//
//  Dealer.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

/**
 Uses shuffling algorithm to deal cards
 */
class Dealer {
    /**
     Shuffles a deck of cards and distribute to players
     - Parameters:
        - players: Who to deal cards to
     - Returns:
        - Players with new hands
     */
    func dealCards(players: [Player]) -> [Player] {
        //TODO: should deal all cards, even if some players end up with more cards
        let cards = Deck(numberOfPackets: 1).shuffled()
        let perPlayer = Int(cards.count / players.count)

        return players.enumerated().map { index, player in
            var player = player

            let startIndex = index * perPlayer
            let endIndex = startIndex + perPlayer

            player.hand = Array(cards[startIndex..<endIndex])
            return player
        }
    }
}
