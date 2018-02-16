//
//  OneTrickIteratorTests.swift
//  PresidentEngineTests
//
//  Created by Daniel Carlos on 10/16/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import XCTest
@testable import PresidentEngine

class OneTrickIteratorTests: XCTestCase {
    var players: [Player] = [
        .init(name: "p1", role: .president),
        .init(name: "p2", role: .vicePresident),
        .init(name: "p3", role: .neutral),
        .init(name: "p4", role: .viceScum),
        .init(name: "p5", role: .scum)
    ]
    let hands: [[Card]] = [ ["3♠︎"], ["4♥︎"], ["5♦︎"], ["6♥︎"], ["7♣︎"] ]
    
    func test_findWinner_withLasPlayFromPresident_returnsPresident() {
        players[0].hand = hands.first!
        players[0].playerOrderer = MockPlayerPlayOrderer()
        let sut = OneTrickIterator(players: players)
        
        let winner = try! sut.findWinner()
        
        XCTAssertEqual(winner, Player(name: "p1", role: .president))
    }
    
    func test_findWinner_withLastPlayFromVicePresident_returnsVicePresident() {
        players[0].hand = hands.first!
        players[0].playerOrderer = MockPlayerPlayOrderer()
        players[1].hand = hands[1]
        players[1].playerOrderer = MockPlayerPlayOrderer()
        let sut = OneTrickIterator(players: players)
        
        let winner = try! sut.findWinner()
        
        XCTAssertEqual(winner, Player(name: "p2", role: .vicePresident))
    }
    
    func test_findWinner_withLasPlayFromScum_returnsScum() {
        for (index, _) in players.enumerated() {
            players[index].hand = hands[index]
            players[index].playerOrderer = MockPlayerPlayOrderer()
        }
        let sut = OneTrickIterator(players: players)
        
        let winner = try! sut.findWinner()
        
        XCTAssertEqual(winner, Player(name: "p5", role: .scum))
    }
    
    class MockPlayerPlayOrderer: PlayerPlayOrderer {
        func nextPlay(forHand hand: [Card]) -> Range<Int> {
            return hand.startIndex..<hand.endIndex
        }
    }
}
