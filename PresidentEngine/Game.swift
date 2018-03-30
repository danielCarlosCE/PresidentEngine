//
//  Game.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/19/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import Foundation

struct Play {
    ///TODO: If the play is not `skip` the array can't be empty. Need to guaratee that somehow
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
    ///TODO: this could not be nil, whether it's cards or skip, the Player needs to play
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

///Responsible for starting a trick and ask for plays until finding a winner
///Validate each play based on the context and rules
///This class doens't know anything about Players, only plays
class TrickIterator {
    private let playOrderer: PlayOrderer
    
    init(playOrderer: PlayOrderer) {
        self.playOrderer = playOrderer
    }

    ///Starts the trick asking for the first play to PlayOrderer
    ///it keeps asking for next plays until the orderer returns nil
    ///it validates each play based on the rules
    ///once it hits the last play, it returns the winner on the @resultCallback closure
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
            guard let firstRank = play.cards.first?.rank else { return }

            let ranks = play.cards.map{ $0.rank }
            try ranks.forEach { rank in
                guard rank == firstRank else { throw Error.cardsDifferentRanks }
            }
        }
        
        func validatePlayHasGreaterRank(play: Play, thanCurrentPlay currentPlay: Play) throws {
            guard let playCardRank = play.cards.first, let currentPlayCardRank = currentPlay.cards.first else { return }
            
            guard playCardRank > currentPlayCardRank else { throw Error.lowerRank }
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

///Responsible for sorting players based on roles [and trick's winner]
///it validates there're exactly 5 players and no repeated role
class PlayersSorter {
    
    func sortByRoles(players: [Player]) throws -> [Player] {
        try validate(players: players)
        
        return players.sorted { $0.role.rawValue < $1.role.rawValue }
    }
    
    func sortByRoles(players: [Player], consideringWinner winner: Player) throws -> [Player] {
        var players = try sortByRoles(players: players)
        
        guard let index = players.index(of: winner) else {
            return players
        }
        
        let winner = players.remove(at: index)
        players.insert(winner, at: 0)
        
        return players
    }
    
    private func validate(players: [Player]) throws {
        let roles = players.map { $0.role }
        
        let rulesValidator = RulesValidator()
        try rulesValidator.validateRolesAreUnique(roles: roles)
    }
    
    private class RulesValidator {
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
    }
}

///Responsible for starting round and for the round's flow (dealing, sorting, tricking, etc)
class RoundIterator {
    var players: [Player]
    init(players: [Player]) {
        self.players = players
    }
    func startRound() throws {
        //while players want to continue
        self.players = dealCards(players: players)
        self.players = try PlayersSorter().sortByRoles(players: players)
        //exchange cards (president-scum; vicePresident-viceScum)

        //playersKeeper
        //while (playersKeeper.players.count > 0)
         //winner = OneTrickIterator.findWinner
         //playersKeeper.kickOffPlayers
         //playersKeeper.players = playersSorter.sortByRoles(players: playersKeeper.players, consideringWinner: winner)

        //reorder based on playersKickedOffOrder
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

///Responsible for find the winner for one trick only
///While TrickIterator tracks only Plays, this class handles Players as wells
class OneTrickIterator {
    fileprivate var players: [Player]
    fileprivate var originalPlayers: [Player]
    fileprivate var playsPlayers: [Play: Player] = [:]

    init(players: [Player]) {
        self.players = players
        self.originalPlayers = players
    }

    ///Ask for each player for exactly one play and return the winner
    func findWinner() throws -> (Player, [Player]) {
        var winner: Player!
        try TrickIterator(playOrderer: self).startTrick { (winningPlay) in
             winner = self.playsPlayers[winningPlay]
        }
        return (winner, originalPlayers)
    }
}

extension OneTrickIterator: PlayOrderer {
    var nextPlay: Play? {
        guard players.count > 0 else { return nil }
        var nextPlayer = players.removeFirst()
        
        guard let play = nextPlayer.nextPlay() else { return nil }
        playsPlayers[play] = nextPlayer
        
        return play
    }
}

///Responsible for keeping players in order after being kicked off without cards
struct PlayersKeeper {
    private(set) var players: [Player]
    private(set) var playersKickedOffOrder: [Player] = []

    init(players: [Player]) {
        self.players = players
    }

    ///Removes players without cards on hand and updates @playersKickedOffOrder
    mutating func kickOffPlayers() {
        players = players.filter {
            guard $0.hand.count > 0 else {
                playersKickedOffOrder.append($0)
                return false
            }
            return true
        }

        if players.count == 1  {
            playersKickedOffOrder.append(players.removeLast())
        }
    }

}
