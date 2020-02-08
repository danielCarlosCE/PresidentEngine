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
    
    var methodsCallsOrder: [Method] = []
    
    func test_startRound_asTemplateMethod() {
        let sut = makeSut(players: playersSample, hands: handsSample)
        
        _ = try! sut.startRound()
        
        XCTAssertEqual(methodsCallsOrder,
                       [.dealCards, .sortByRoles, .findWinner, .sortByRolesConsideringWinner])
    }
    
    func test_startRound_withWinningSameOrder_returnSameOrder() {
        let sut = makeSut(players: playersSample, hands: handsSample)
        
        let result = try! sut.startRound()
        
        XCTAssertEqual(result, ["p1", "p2", "p3", "p4", "p5"])
    }
    
    func test_startRound_withMultipleTricksLasting_returnRightOrder() {
        let hands: [[Card]] = [
            ["J♠︎", "Q♠︎"], ["Q♥︎", "2♣︎"], ["10♦︎", "10♥︎"], ["6♥︎", "7♥︎"], ["3♣︎", "4♥︎"]
        ]
        let plays: [PlayerPlaysOrdererPlay] =
            [.go(["J♠︎"]), .go(["Q♥︎"]), .skip, .skip, .skip,
             .go(["2♣︎"]), .skip, .skip, .skip, .skip,
             .go(["Q♠︎"]), .skip, .skip, .skip,
             .go(["10♦︎", "10♥︎"]), .skip, .skip,
             .go(["6♥︎"]), .skip,
             .go(["7♥︎"]), .skip]
        
        let sut = makeSut(players: players(withPlays: plays), hands: hands)
        
        let result = try! sut.startRound()
        
        XCTAssertEqual(result, ["p2", "p1", "p3", "p4", "p5"])
    }
}

extension RoundIteratorTests {
    private func makeSut(players: [Player], hands: [[Card]] = []) -> RoundIterator {
        let addMethod: (Method) -> Void = { self.methodsCallsOrder.append($0) }
        let dealer = MockDealer(hands: hands, addMethod: addMethod)
        let sorter = MockPlayersSorter(addMethod: addMethod)
        MockOnePlayPerPlayerTrickIterator.addMethod = addMethod
        let OnePlayPerPlayerTrickIteratorType = MockOnePlayPerPlayerTrickIterator.self
        
        let sut = RoundIterator(players: players, dealer: dealer, sorter: sorter, OnePlayPerPlayerTrickIteratorType: OnePlayPerPlayerTrickIteratorType)
        return sut
    }
    
    private var playersSample: [Player] {
        let players = PlayersFactory.make([
            ("p1", "president"),
            ("p2", "vice-president"),
            ("p3", "neutral"),
            ("p4", "vice-scum"),
            ("p5", "scum")
        ])
        
        let orderer = MockPlayerPlaysOrderer()
        return players.map {
            var player = $0
            player.playsOrderer = orderer
            return player
        }
    }
    
    private var handsSample: [[Card]] { [["3♠︎"], ["4♥︎"], ["5♦︎"], ["6♥︎"], ["7♣︎"]] }
    
    private func players(withPlays plays: [PlayerPlaysOrdererPlay]) -> [Player] {
        let orderer = MockPlayerPlaysOrderer(plays: plays)
        return playersSample.map {
            var player = $0
            player.playsOrderer = orderer
            return player
        }
    }
    
    class MockPlayerPlaysOrderer: PlayerPlaysOrderer {
        private var plays: [PlayerPlaysOrdererPlay]
        init(plays: [PlayerPlaysOrdererPlay] = []) {
            self.plays = plays
        }
        func nextPlay(forHand hand: [Card]) -> PlayerPlaysOrdererPlay {
            guard !plays.isEmpty else {
                return .go(hand.startIndex..<hand.endIndex)
            }
            return plays.removeFirst()
        }
    }
}

extension PlayerPlaysOrdererPlay {
    static func go(_ cards: [Card]) -> PlayerPlaysOrdererPlay {
        PlayerPlaysOrdererPlay.go(cards.startIndex..<cards.endIndex)
    }
}

enum Method {
    case dealCards
    case sortByRoles
    case findWinner
    case sortByRolesConsideringWinner
}

class MockDealer: Dealer {
    var addMethod: (Method) -> Void
    var hands: [[Card]]
    init(hands: [[Card]], addMethod: @escaping (Method) -> Void) {
        self.hands = hands
        self.addMethod = addMethod
    }
    override func dealCards(players: [Player]) -> [Player]  {
        addMethod(.dealCards)
        return players.enumerated().map {
            var player = $1
            player.hand = hands[$0]
            return player
        }
    }
}

class MockPlayersSorter: PlayersSorter {
    var addMethod: (Method) -> Void
    init(addMethod: @escaping (Method) -> Void) {
        self.addMethod = addMethod
    }
    override func sortByRoles(players: [Player]) throws -> [Player] {
        addMethod(.sortByRoles)
        return try super.sortByRoles(players: players)
    }
    
    override func sortByRoles(players: [Player], consideringWinner winner: Player) throws -> [Player] {
        addMethod(.sortByRolesConsideringWinner)
        
        // the current implementation calls `sortByRoles(players:)` at this point
        // we can't not rely on this implementation detail to check methods calls order
        // that's why we're not calling super here
        var players = players.sorted { $0.role.rawValue > $1.role.rawValue }
        guard let index = players.firstIndex(of: winner) else { return players }
        players.remove(at: index)
        players.insert(winner, at: 0)
        return players
    }
}

class MockOnePlayPerPlayerTrickIterator: OnePlayPerPlayerTrickIterator {
    static var addMethod: ((Method) -> Void)?
    
    override func findWinner() throws -> (Player, [Player]) {
        MockOnePlayPerPlayerTrickIterator.addMethod!(.findWinner)
        return try super.findWinner()
    }
}

