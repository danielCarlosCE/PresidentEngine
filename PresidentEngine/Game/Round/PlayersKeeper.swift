//
//  PlayersKeeper.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

/**
 Keeps players in order after being kicked off without cards
 */
class PlayersKeeper {
    var players: [Player]
    private(set) var playersOrdered: [Player] = []
    
    init(players: [Player]) {
        self.players = players
    }
    
    /**
     Removes players without cards on hand
     */
    func kickOffPlayersWithoutCards() {
        players = players.filter {
            guard $0.hand.count > 0 else {
                playersOrdered.append($0)
                return false
            }
            return true
        }
        
        if players.count == 1  {
            playersOrdered.append(players.removeLast())
        }
    }
    
}
