//
//  PlayersSorterTests.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/22/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

@testable import PresidentEngine
import XCTest

class PlayersSorterTests: XCTestCase {
    
    typealias Player = String
    typealias Role = String
    
    var sut: PlayersSorter!
    
    override func setUp() {
        super.setUp()
        sut = PlayersSorter()
    }
    
    func testSortByRoles_withUnorderedRoles_orders() {
        let playersRoles: [Player: Role] = ["p1": "vice-scum", "p2": "vice-president", "p3": "president", "p4": "scum", "p5": "neutral"]
        
        let playersOrdered:  [Player] = try! sut.sortByRoles(playersRoles: playersRoles)
        
        XCTAssertEqual(playersOrdered, ["p3", "p2","p5", "p1", "p4"])
    }
    
    func testSortByRoles_withOrderedRoles_returnSame() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"])
        
        let playersOrdered: [Player] = try! sut.sortByRoles(playersRoles: playersRoles)
        
        XCTAssertEqual(playersOrdered, ["p1", "p2", "px", "p3", "p4"])
    }
    
    func testSortByRoles_withNot5Players_throwsError() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "p3": "vice-scum", "p4": "scum"])
        
        
        XCTAssertThrows(try sut.sortByRoles(playersRoles: playersRoles), specificError: PlayersSorter.Error.invalidNumberPlayers)
    }
    
    func testSortByRoles_withUnknownRoles_throwsError() {
        let playersRoles = makePlayersRoles(["p1": "invalidRole", "p2": "vice-president", "p3": "vice-scum", "p4": "scum", "p5": "president"])
        
        XCTAssertThrows(try sut.sortByRoles(playersRoles: playersRoles), specificError: PlayersSorter.Error.invalidRole)
    }
    
    func testSortByRoles_withRepeatedRoles_throwsError() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "p3": "vice-scum", "p4": "scum", "p5": "president"])
        
        XCTAssertThrows(try sut.sortByRoles(playersRoles: playersRoles), specificError: PlayersSorter.Error.repeatedRoles)
    }
    
    //Mark: privates
    private func makePlayersRoles(_ playersRoles: [Player: Role]) -> [Player: Role] {
        return playersRoles
    }
    
}
