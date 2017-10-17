//
//  Game.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/19/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import Foundation

typealias Play = [Card]

enum Role: Int {
    case president
    case vicePresident
    case neutral
    case viceScum
    case scum
}

struct Player {
    var name: String
    var role: Role
    var hand: [Card] = []
    
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
        return lhs.value == rhs.value && lhs.rank == rhs.rank
    }
}


protocol PlayOrderer {
    var nextPlay: Play? {get}
}

class TrickIterator {
    private let playOrderer: PlayOrderer
    
    init(playOrderer: PlayOrderer) {
        self.playOrderer = playOrderer
    }
    
    func startTrick(resultCallback: (Play) -> Void) throws {
        var currentPlay: Play?
        
        while let nextPlay = playOrderer.nextPlay {
            try validate(nextPlay, forCurrentPlay: currentPlay)
            currentPlay = nextPlay
        }
        
        let ordererHasNoPlays = (currentPlay == nil)
        if ordererHasNoPlays {
            throw Error.nonePlaysFromOrderer
        }
        
        resultCallback(currentPlay!)
    }
    
    private func validate(_ nextPlay: Play, forCurrentPlay currentPlay: Play?) throws {
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
        case nonePlaysFromOrderer
    }
}

class PlayersSorter {
    
    func sortByRoles(players: [Player]) throws -> [Player] {
        try validate(players: players)

        var players = players
        for player in players {
            let correctRoleIndex = player.role.rawValue
            players[correctRoleIndex] = player
        }
        
        return players
    }
    
    func sortByRoles(players: [Player], consideringWinner winner: Player) throws -> [Player] {
        var players = try sortByRoles(players: players)
        
        guard let index = players.index(of: winner) else {
            throw Error.givenWinnerNotPlaying
        }
        
        let winner = players.remove(at: index)
        players.insert(winner, at: 0)
        
        return players
    }
    
    private func validate(players: [Player]) throws {
        let roles = players.map { $0.role }
        
        let rulesValidator = RulesValidator()
        try rulesValidator.validateThereAreExactlyFivePlayers(players: players)
        try rulesValidator.validateRolesAreUnique(roles: roles)
    }
    
    private class RulesValidator {
        func validateThereAreExactlyFivePlayers(players: [Player]) throws {
            guard players.count == 5 else { throw Error.invalidNumberPlayers }
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
        case repeatedRoles
        case givenWinnerNotPlaying
    }
}

class RoundIterator {
    var players: [Player]
    init(players: [Player]) {
        self.players = players
    }
    func startRound() throws {
        self.players = dealCards(players: players)
        self.players = try PlayersSorter().sortByRoles(players: players)
    }
    
    private func dealCards(players: [Player]) -> [Player] {
        let cards = Deck(numberOfPackets: 1).shuffled()
        //TODO: show reminder somehow
        let perPlayer = Int(cards.count / players.count)
        
        return players.enumerated().map { index, player in
            var player = player
            
            let startIndex = index * perPlayer
            let endIndex = startIndex + perPlayer
            
            player.hand = Array(cards[startIndex..<endIndex])
            return player
        }
    }
}
