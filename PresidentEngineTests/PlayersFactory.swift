//
//  PlayersFactory.swift
//  PresidentEngineTests
//
//  Created by HE:labs on 15/02/18.
//  Copyright © 2018 danielcarlosce. All rights reserved.
//

@testable import PresidentEngine

class PlayersFactory {

    typealias PlayerName = String
    typealias RoleValue = String

    ///make(["p1": "president", "p2": "vice-president", "px": "neutral", "p3": "vice-scum", "p4": "scum"])
    static func make(_ playersRoles: [PlayerName: RoleValue]) -> [Player] {
        return playersRoles.map { return Player(name: $0.key, role: .init(stringLiteral: $0.value)) }
    }

    static func make(_ playersRoles: [PlayerName: RoleValue], withHands hands: [[Card]]) -> [Player] {
        return make(playersRoles).enumerated().map {
            var player = $0.element
            player.hand = hands[$0.offset]
            return player
        }
    }
}
