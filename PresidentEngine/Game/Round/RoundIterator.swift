//
//  RoundIterator.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

 /**
 Navigates through a round
 */
class RoundIterator {
    private let dealer: Dealer
    private var keeper: PlayersKeeper
    private var sorter: PlayersSorter
    private var OnePlayPerPlayerTrickIteratorType: OnePlayPerPlayerTrickIterator.Type
    
    init(players: [Player],
         dealer: Dealer = Dealer(),
         sorter: PlayersSorter = PlayersSorter(),
         OnePlayPerPlayerTrickIteratorType: OnePlayPerPlayerTrickIterator.Type = OnePlayPerPlayerTrickIterator.self) {
        
        self.dealer = dealer
        self.keeper = PlayersKeeper(players: players)
        self.sorter = sorter
        self.OnePlayPerPlayerTrickIteratorType = OnePlayPerPlayerTrickIteratorType
    }
    
    /**
     Keeps the round alive until every player is out of cards or there's only one player left.
     
     The player's roles are not changed by this method
     
     - Returns:
        - players ordered by order they run out of cards
     */
    func startRound() throws -> [Player] {
        keeper.players = dealer.dealCards(players: keeper.players)
        
        keeper.players = try sorter.sortByRoles(players: keeper.players)
        
        //TODO: exchange cards (president-scum; vicePresident-viceScum)
        
        while keeper.players.count > 0 {
            let (winner, players) = try OnePlayPerPlayerTrickIteratorType.init(players: keeper.players).findWinner()
            
            keeper.players = players
            keeper.kickOffPlayersWithoutCards()
    
            keeper.players = try sorter.sortByRoles(players: keeper.players, consideringWinner: winner)
        }
        
        return keeper.playersOrdered
    }
    
}
