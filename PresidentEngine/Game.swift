//
//  Game.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/19/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import Foundation

struct Play {
    let cards: [Card]
}

extension Play: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Card...) {
        self.cards = elements
    }
    
    typealias ArrayLiteralElement = Card
}

extension Play: Hashable {
    static func ==(lhs: Play, rhs: Play) -> Bool {
        return lhs.cards == rhs.cards
    }
    var hashValue: Int {
        return self.cards.map{$0.hashValue}.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
}

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
    var playerOrderer: PlayerPlayOrderer?
    
    init(name: String, role: Role) {
        self.name = name
        self.role = role
    }
}

protocol PlayerPlayOrderer {
    func nextPlay(forHand: [Card]) -> Range<Int>
}

extension Player {
    mutating func nextPlay() -> Play? {
        if let playOrderer = playerOrderer {
            let range = playOrderer.nextPlay(forHand: hand)
            let play = Array(hand[range])
            hand.removeSubrange(range)
            return Play(cards: play)
        }
        return nil
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

extension Card: Hashable {
    var hashValue: Int {
        return "\(rank.rawValue)\(suit.rawValue)".hashValue
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
            if let firstRank = play.cards.first?.rank {
                for rank in (play.cards.map{ $0.rank }) {
                    guard rank == firstRank else {
                        throw Error.cardsDifferentRanks
                    }
                }
            }
        }
        
        func validatePlayHasGreaterRank(play: Play, thanCurrentPlay currentPlay: Play) throws {
            guard let playCardRank = play.cards.first, let currentPlayCardRank = currentPlay.cards.first else { return }
            
            guard playCardRank > currentPlayCardRank else {
                throw Error.lowerRank
            }
        }
        
        func validatePlayHasRightNumberCards(play: Play, asCurrentPlay currentPlay: Play) throws {
            let hasSameNumberCards = (play.cards.count == currentPlay.cards.count)
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

class OneTrick {
    private var players: [Player]
    private var playsPlayers: [Play: Player] = [:]

    init(players: [Player]) {
        self.players = players
    }
    
    func findWinner() throws -> Player {
        var winner: Player!
        try TrickIterator(playOrderer: self).startTrick { (winningPlay) in
             winner = self.playsPlayers[winningPlay]
        }
        return winner
    }
}

extension OneTrick: PlayOrderer {
    var nextPlay: Play? {
        guard players.count > 0 else { return nil }
        var nextPlayer = players.removeFirst()
        
        guard let play = nextPlayer.nextPlay() else { return nil }
        playsPlayers[play] = nextPlayer
        
        return play
    }
}
