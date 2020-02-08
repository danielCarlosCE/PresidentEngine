//
//  OnePlayPerPlayerTrickIterator.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

/**
 Relates to a single trick, where each player can play only once
 */
class OnePlayPerPlayerTrickIterator: PlayOrderer {
    fileprivate var players: [Player]
    fileprivate var originalPlayers: [Player]
    fileprivate var playsPlayers: [Play: Player] = [:]
    
    required init(players: [Player]) {
        self.players = players
        self.originalPlayers = players
    }
    
    /**
     Goes around asking each player for a valid play
     
     Each play is validated through a set of rules.
     
     - Returns:
     - The winner - the last one to play cards
     - The players with updated hands
     */
    func findWinner() throws -> (Player, [Player]) {
        var winner: Player!
        try TrickIterator(playOrderer: self).startTrick { (winningPlay) in
            winner = self.playsPlayers[winningPlay]
        }
        return (winner, originalPlayers)
    }
    
    var nextPlay: Play? {
        guard players.count > 0 else { return nil }
        var nextPlayer = players.removeFirst()
        
        let play = nextPlayer.nextPlay()
        playsPlayers[play] = nextPlayer
        
        let index = originalPlayers.firstIndex(of: nextPlayer)!
        originalPlayers[index] = nextPlayer
        
        return play
    }
}
