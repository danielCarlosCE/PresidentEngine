//
//  Game.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/19/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import Foundation

typealias Play = [Card]

struct Card {
    let rank: Rank
    enum Rank: Int {
        case aces = 1
        case two, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king
    }
}

extension Card: Comparable {
    var value: Int {
        switch self.rank {
        case .aces:
            return 14
        case .two:
            return 15
        default:
            return self.rank.rawValue
        }
    }
    
    public static func <(lhs: Card, rhs: Card) -> Bool {
        return lhs.value < rhs.value
    }
    
    public static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.value == rhs.value
    }
}


protocol PlayOrderer {
    var nextPlay: Play? {get}
}

class TrickIterator {
    private let playOrderer: PlayOrderer
    private var currentPlay: Play?
    
    init(playOrderer: PlayOrderer) {
        self.playOrderer = playOrderer
    }
    
    func startTrick(resultCallback: (Play?) -> Void) throws {
        
        while let nextPlay = playOrderer.nextPlay {
            try validate(nextPlay)
            currentPlay = nextPlay
        }
        
        resultCallback(currentPlay)
    }
    
    private func validate(_ nextPlay: Play) throws {
        let rulesValidator = RulesValidator()
        
        try rulesValidator.validatePlayHasOnlyOneRank(play: nextPlay)
        
        if let currentPlay = currentPlay  {
            try rulesValidator.validatePlayHasRightNumberCards(play: nextPlay, asCurrentPlay: currentPlay)
            try rulesValidator.validatePlayHasGreaterRank(play: nextPlay, thanCurrentPlay: currentPlay)
        }

    }
    
    private class RulesValidator {
        func validatePlayHasOnlyOneRank(play: Play) throws {
            if let firstRank = play.first {
                for rank in play {
                    guard rank == firstRank else {
                        throw Error.cardsDifferentRanks
                    }
                }
            }
        }
        
        func validatePlayHasGreaterRank(play: Play, thanCurrentPlay currentPlay: Play) throws {
            guard let playCardRank = play.first, let currentPlayCardRank = currentPlay.first else { return }
            
            guard playCardRank > currentPlayCardRank else {
                throw Error.lowerRank
            }
        }
        
        func validatePlayHasRightNumberCards(play: Play, asCurrentPlay currentPlay: Play) throws {
            let hasSameNumberCards = (play.count == currentPlay.count)
            guard hasSameNumberCards else {
                throw Error.invalidNumberCards
            }
        }
    }
    
    enum Error: Swift.Error {    
        case lowerRank
        case invalidNumberCards
        case cardsDifferentRanks
    }
}

/// named by @leandroico, thanks/blame him
class PlayersSorter {
    typealias Player = String
    typealias Role = String
    
    let orderedRoles = ["president", "vice-president", "neutral", "vice-scum", "scum"]
    
    func sortByRoles(playersRoles: [Player: Role]) throws -> [Player] {
        try validate(playersRoles: playersRoles)

        var players = Array(playersRoles.keys)
        for (player, role) in playersRoles {
            let correctRoleIndex = orderedRoles.index(of: role)!
            players[correctRoleIndex] = player
        }
        
        return players
    }
    
    private func validate(playersRoles: [Player: Role]) throws {
        let players = Array(playersRoles.keys)
        let roles = Array(playersRoles.values)
        
        let rulesValidator = RulesValidator()
        try rulesValidator.validateThereAreExactlyFivePlayers(players: players)
        try rulesValidator.validateRolesExist(roles: roles, in: orderedRoles)
        try rulesValidator.validateRolesAreUnique(roles: roles)
    }
    
    private class RulesValidator {
        func validateThereAreExactlyFivePlayers(players: [Player]) throws {
            guard players.count == 5 else { throw Error.invalidNumberPlayers }
        }
        
        func validateRolesExist(roles: [Role], in knownRoles: [Role]) throws {
            for role in roles {
                guard knownRoles.contains(role) else {
                    throw Error.invalidRole
                }
            }
        }
        
        func validateRolesAreUnique(roles: [Role]) throws {
            for role in roles {
                guard (roles.filter { $0 == role }).count == 1 else {
                    throw Error.repeatedRoles
                }
            }
        }
    }
    
    enum Error: Swift.Error {
        case invalidNumberPlayers
        case invalidRole
        case repeatedRoles
    }
}

