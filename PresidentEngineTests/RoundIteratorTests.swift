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

    var players: [Player] = []

    override func setUp() {
        players = playersWithSimplePlaysOrderer
    }

    func testStartRound_withOneTrick_iteratesRightOrder() {
        let sut = makeSut(for: players)

        _ = try! sut.startRound()

        XCTAssertEqual(sut.methodsCallsOrder,
                        [.dealCards, .sortByRoles, .findWinner, .sortByRolesConsideringWinner])
    }

    func testStartRound_withWinningSameOrder_returnSameOrder() {
        let sut = makeSut(for: players)

        let roundResult: [Player] = try! sut.startRound()

        XCTAssertEqual(roundResult, ["p1", "p2", "p3", "p4", "p5"])
    }

    func testStartRound_withMultipleTricksLasting_returnRightOrder() {

        let hands: [[Card]] = [
            ["J♠︎", "Q♠︎"], ["Q♥︎", "2♣︎"], ["10♦︎", "10♥︎"], ["6♥︎", "7♥︎"], ["3♣︎", "4♥︎"]
        ]
        let plays: [PlayerPlaysOrdererPlay] =
            [.go(0..<1), .go(0..<1), .skip, .skip, .skip,
             .go(0..<1), .skip, .skip, .skip, .skip,
             .go(0..<1), .skip, .skip, .skip,
             .go(0..<2), .skip, .skip,
             .go(0..<1), .skip,
             .go(0..<1), .skip,
             .go(0..<1),
             .go(0..<1)]

        let playsOrderer = PlaysOrderer(plays: plays)
        let players = playersWithoutPlaysOrderer.map { player -> Player in
            var player = player
            player.playsOrderer = playsOrderer
            return player
        }
        let sut = makeSut(for: players)
        sut.hands = hands

        let roundResult: [Player] = try! sut.startRound()

        XCTAssertEqual(roundResult, ["p2", "p1", "p3", "p4", "p5"])
    }


    // MARK: Helpers

    private func makeSut(for players: [Player]) -> MockRoundIterator {
        return MockRoundIterator(players: players)
    }

    private var playersWithoutPlaysOrderer: [Player] {
        return [.init(name: "p1", role: .president),
                .init(name: "p2", role: .vicePresident),
                .init(name: "p3", role: .neutral),
                .init(name: "p4", role: .viceScum),
                .init(name: "p5", role: .scum)]
    }

    private var playersWithSimplePlaysOrderer: [Player] {
        let playsOrderer = PlaysOrderer()
        return playersWithoutPlaysOrderer.map { (player: Player) -> Player in
                    var player = player
                    player.playsOrderer = playsOrderer
                    return player
        }
    }

    class PlaysOrderer: PlayerPlaysOrderer {
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

class MockRoundIterator: RoundIterator {
    var methodsCallsOrder: [Method] = []
    var hands: [[Card]] = [ ["3♠︎"], ["4♥︎"], ["5♦︎"], ["6♥︎"], ["7♣︎"] ]

    override func dealCards(players: [Player]) -> [Player]  {
        methodsCallsOrder.append(.dealCards)
        return players.enumerated().map {
            var player = $1
            player.hand = hands[$0]
            return player
        }
    }

    override func sortByRoles(players: [Player]) throws -> [Player] {
        methodsCallsOrder.append(.sortByRoles)
        return try super.sortByRoles(players: players)
    }

    override func findWinner(players: [Player]) throws -> (Player, [Player]) {
        methodsCallsOrder.append(.findWinner)
        return try super.findWinner(players: players)
    }

    override func sortByRoles(players: [Player], consideringWinner winner: Player) throws -> [Player] {
        methodsCallsOrder.append(.sortByRolesConsideringWinner)
        return try super.sortByRoles(players: players, consideringWinner: winner)
    }

    enum Method {
        case dealCards
        case sortByRoles
        case findWinner
        case sortByRolesConsideringWinner
    }
}


