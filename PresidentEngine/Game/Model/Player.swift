//
//  Player.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

struct Player {
    var name: String
    var role: Role
    var hand: [Card] = []
    var playsOrderer: PlayerPlaysOrderer?
    
    init(name: String, role: Role) {
        self.name = name
        self.role = role
    }
}

extension Player: Equatable {
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Player {
    mutating func nextPlay() -> Play {
        if let playOrderer = playsOrderer {
            guard case let .go(range) = playOrderer.nextPlay(forHand: hand)  else { return .skip }

            let cards = Array(hand[range])
            hand.removeSubrange(range)
            print(cards.map { "\($0.rank)\($0.suit)" })
            return .go(cards)
        }
        return .skip
    }
}


