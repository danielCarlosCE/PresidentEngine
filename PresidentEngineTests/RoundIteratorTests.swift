//
//  RoundIteratorTests.swift
//  PresidentEngineTests
//
//  Created by Daniel Carlos on 10/15/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import XCTest
@testable import PresidentEngine

class RoundIteratorTests: XCTestCase {
    
    let players: [Player] = [
        .init(name: "p1", role: .president),
        .init(name: "p2", role: .vicePresident),
        .init(name: "p3", role: .neutral),
        .init(name: "p4", role: .viceScum),
        .init(name: "p5", role: .scum)
    ]
    
    func test_startRound_dealsCards() {
        let sut = RoundIterator(players: players)
        
        try! sut.startRound()
        
        let hands: [[Card]] = sut.players.map { $0.hand }
        let noEmptyHand = hands.filter{$0.count > 0}.count == hands.count
        XCTAssert(noEmptyHand)
    }
    
    func test_startRound_dealsSameNumberOfCards() {
        let sut = RoundIterator(players: players)
        
        try! sut.startRound()
        
        let hands: [[Card]] = sut.players.map { $0.hand }
        let handsSameNumberCards = Set(hands.map {$0.count}).count == 1
        XCTAssertTrue(handsSameNumberCards)
    }
    
    func test_startRound_ordersByRole() {
        var players = self.players
        players.swapAt(0, 1)
        let sut = RoundIterator(players: players)
        
        try! sut.startRound()
        
        let roundPlayers = sut.players
        XCTAssertEqual(roundPlayers, self.players)
    }
    
   

    /*
     while()
     //start round (a set of tricks, until everyone is done with cards)
     
     //first deal cards - CardsDealear
     //order by roles, before starting trick
     //exchange cards (president-scum; vicePresident-viceScum)
     
     while()
     
     //start trick
     //ask for each play until we have a winner, keeping updating player's hands
     //we need to keep track of players and theirs plays to be able to determine who won //PlayersManager
     
     //here we'll cut from the game anyone who is done with cards, and keep track of their (new) position
     //here we'll have new order for the next trick if president didn't win this trick, putting winner in front of president
     
     //here we'll go to the next trick only if we still have a minimum of 2 players with cards //PlayersManager
     
     //if only 1 or 0 players remain,
     save round result,
     give new roles and
     ask if want continue playing
     
     //if want continue playing, then start new round
     //else, end game and show rounds results
     */
}

extension Player: CustomStringConvertible {
    public var description: String {
        return "\(name): \(role)"
    }
}
