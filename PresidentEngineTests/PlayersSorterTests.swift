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
    
    var sut: PlayersSorter!
    
    override func setUp() {
        super.setUp()
        sut = PlayersSorter()
    }
    
    func testSortByRoles_withUnorderedRoles_orders() {
        let playersRoles = makePlayersRoles(["p1": "vice-scum", "p2": "vice-president", "p3": "president", "p4": "scum", "p5": "neutral"])
        
        let playersOrdered:  [Player] = try! sut.sortByRoles(players: playersRoles)
        
        XCTAssertEqual(playersOrdered, ["p3", "p2","p5", "p1", "p4"])
    }
    
    func testSortByRoles_withOrderedRoles_returnSame() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"])
        
        let playersOrdered: [Player] = try! sut.sortByRoles(players: playersRoles)
        
        XCTAssertEqual(playersOrdered, ["p1", "p2", "px", "p3", "p4"])
    }
    
    func testSortByRoles_withNot5Players_throwsError() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "p3": "vice-scum", "p4": "scum"])
        
        
        XCTAssertThrows(try sut.sortByRoles(players: playersRoles), specificError: PlayersSorter.Error.invalidNumberPlayers)
    }
    
    func testSortByRoles_withRepeatedRoles_throwsError() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "p3": "vice-scum", "p4": "scum", "p5": "president"])
        
        XCTAssertThrows(try sut.sortByRoles(players: playersRoles), specificError: PlayersSorter.Error.repeatedRoles)
    }
    
    func testSortByRolesConsideringWinner_withPresidentWinning_keepsSameOrder() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"])
        let winner: Player = "p1"
       
        let playersOrdered: [Player] = try! sut.sortByRoles(players: playersRoles, consideringWinner: winner)
        
        XCTAssertEqual(playersOrdered, ["p1", "p2", "px", "p3", "p4"])
    }
    
    func testSortByRolesConsideringWinner_withViceWinning_changesOrder() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"])
        let winner: Player = "p2"
        
        let playersOrdered: [Player] = try! sut.sortByRoles(players: playersRoles, consideringWinner: winner)
        
        XCTAssertEqual(playersOrdered, ["p2", "p1", "px", "p3", "p4"])
    }
    
    func testSortByRolesConsideringWinner_withScrumWinning_changesOrder() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"])
        let winner: Player = "p4"
        
        let playersOrdered: [Player] = try! sut.sortByRoles(players: playersRoles, consideringWinner: winner)
        
        XCTAssertEqual(playersOrdered, ["p4", "p1", "p2", "px", "p3"])
    }
    
    func testSortByRolesConsideringWinner_withWinnerNotPlaying_throwsError() {
        let playersRoles = makePlayersRoles(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"])
        let winner: Player = "pz"
        
        XCTAssertThrows(try sut.sortByRoles(players: playersRoles, consideringWinner: winner), specificError: PlayersSorter.Error.givenWinnerNotPlaying)
    }
    
    //Mark: privates
    private func makePlayersRoles(_ playersRoles: [String: String]) -> [Player] {
        return playersRoles.map { return Player(name: $0.key, role: .init(stringLiteral: $0.value)) }
    }
    
}

//when the roles doesn't matter
extension Player: ExpressibleByStringLiteral {
    public init(stringLiteral value: String)  {
        self.init(value: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(value: value)
    }
    
    private init(value: String) {
        self.init(name: value, role: .president)
    }
}
extension Role: ExpressibleByStringLiteral {
    public init(stringLiteral value: String)  {
        self.init(value: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(value: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String)  {
        self.init(value: value)
    }
    
    private init(value: String) {
        switch value {
        case "president":
            self = .president
        case "vice-president":
            self = .vicePresident
        case "neutral":
            self = .neutral
        case "vice-scum":
            self = .viceScum
        case "scum":
            self = .scum
            
        default:
            fatalError("Unkown value for creating role: \(value)")
        }
    }
}
