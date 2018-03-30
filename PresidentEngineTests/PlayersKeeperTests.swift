//
//  PlayersKeeperTests.swift
//  PresidentEngineTests
//
//  Created by HE:labs on 15/02/18.
//  Copyright © 2018 danielcarlosce. All rights reserved.
//

import XCTest
@testable import PresidentEngine

class PlayersKeeperTests: XCTestCase {

    var usersFactory = PlayersFactory.self

    func testKickOffPlayers_withOneEmptyHandPlayer_removesPlayer() {
        let players: [Player] = usersFactory.make(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"],
                                                  withHands: [ [], ["4♥︎"], ["5♦︎"], ["6♥︎"], ["7♣︎"] ] )
        var sut = PlayersKeeper(players: players)

        sut.kickOffPlayersWithoutCards()

        XCTAssertEqual(sut.playersWithCards, usersFactory.make(["p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"]))
    }

    func testKickOfPlayers_withNoEmptyHandPlayers_removesNone() {
        let players: [Player] = usersFactory.make(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"],
                                                  withHands: [ ["3♣︎"], ["3♠︎"], ["4♥︎"], ["5♦︎"], ["6♥︎"], ["7♣︎"] ] )
        var sut = PlayersKeeper(players: players)

        sut.kickOffPlayersWithoutCards()

        XCTAssertEqual(sut.playersWithCards, usersFactory.make(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"]))
    }

    func testPlayersKickedOffOrder_withOnePlayerOff_returnsPlayer() {
        let players: [Player] = usersFactory.make(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"],
                                                  withHands: [ [], ["4♥︎"], ["5♦︎"], ["6♥︎"], ["7♣︎"] ] )
        var sut = PlayersKeeper(players: players)

        sut.kickOffPlayersWithoutCards()

        XCTAssertEqual(sut.playersKickedOffOrder, usersFactory.make(["p1": "president"]))
    }

    func testPlayersKickedOffOrder_withNoPlayersOff_returnsNone() {
        let players: [Player] = usersFactory.make(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"],
                                                  withHands: [ ["3♣︎"], ["4♥︎"], ["5♦︎"], ["6♥︎"], ["7♣︎"] ] )
        var sut = PlayersKeeper(players: players)

        sut.kickOffPlayersWithoutCards()

        XCTAssertEqual(sut.playersKickedOffOrder, [])
    }

    func testPlayersKickedOffOrder_withOneRemaining_returnsAll() {
        let players: [Player] = usersFactory.make(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"],
                                                  withHands: [ [], [], [], [], ["7♣︎"] ] )
        var sut = PlayersKeeper(players: players)

        sut.kickOffPlayersWithoutCards()

        XCTAssertEqual(sut.playersKickedOffOrder, usersFactory.make(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"]))
    }

}
