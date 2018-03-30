//
//  Game.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/19/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import Foundation

enum Play {
    //TODO: If the play is not `skip` the array can't be empty. Need to guaratee that somehow
    case go([Card])
    case skip
}

extension Play: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Card...) {
        self = .go(elements)
    }
    
    typealias ArrayLiteralElement = Card
}

extension Play: Hashable {
    static func ==(lhs: Play, rhs: Play) -> Bool {
        switch (lhs, rhs) {
        case (.skip, .skip): return true
        case (.go(let cardslhs), .go(let cardsrhs)):
            return cardslhs == cardsrhs
        default: return false
        }

    }
    var hashValue: Int {
        switch self {
        case .go(let cards):
            return cards.map{$0.hashValue}.reduce(5381) {
                ($0 << 5) &+ $0 &+ Int($1)
            }
        case .skip:
            return 0
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
    var playsOrderer: PlayerPlaysOrderer?
    
    init(name: String, role: Role) {
        self.name = name
        self.role = role
    }
}

protocol PlayerPlaysOrderer {
    func nextPlay(forHand: [Card]) -> PlayerPlaysOrdererPlay
}

enum PlayerPlaysOrdererPlay {
    case go(Range<Int>)
    case skip
}

extension Player {
    mutating func nextPlay() -> Play {
        if let playOrderer = playsOrderer {
            guard case let .go(range) = playOrderer.nextPlay(forHand: hand)  else { return .skip }

            let cards = Array(hand[range])
            hand.removeSubrange(range)
            return .go(cards)
        }
        return .skip
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
        var currentPlay: [Card]?
        
        while let nextPlay = playOrderer.nextPlay {
            try validate(nextPlay, forCurrentPlay: currentPlay)
            if case let .go(cards) = nextPlay {
                currentPlay = cards
            }
        }
        
        guard let ordererLastPlay = currentPlay else {
            throw Error.nonePlaysFromOrderer
        }
        
        resultCallback(.go(ordererLastPlay))
    }
    
    private func validate(_ nextPlay: Play, forCurrentPlay currentPlay: [Card]?) throws {
        let rulesValidator = RulesValidator()
        try rulesValidator.validatePlayHasOnlyOneRank(play: nextPlay)

        guard let currentPlay = currentPlay else { return }
        try rulesValidator.validatePlayHasRightNumberCards(play: nextPlay, asCurrentPlay: currentPlay)
        try rulesValidator.validatePlayHasGreaterRank(play: nextPlay, thanCurrentPlay: currentPlay)


    }
    
    private class RulesValidator {
        func validatePlayHasOnlyOneRank(play: Play) throws {
            guard case let .go(cards) = play, let firstRank = cards.first?.rank else { return }

            let ranks = cards.map{ $0.rank }
            try ranks.forEach { rank in
                guard rank == firstRank else { throw Error.cardsDifferentRanks }
            }
        }
        
        func validatePlayHasGreaterRank(play: Play, thanCurrentPlay currentPlay: [Card]) throws {
            guard case let .go(cards) = play, let playCardRank = cards.first, let currentPlayCardRank = currentPlay.first else { return }
            
            guard playCardRank > currentPlayCardRank else { throw Error.lowerRank }
        }
        
        func validatePlayHasRightNumberCards(play: Play, asCurrentPlay currentPlay: [Card]) throws {
            guard case let .go(cards) = play else { return }
            let hasSameNumberCards = (cards.count == currentPlay.count)
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
    private let dealer = Dealer()
    private var keeper: PlayersKeeper
    private var sorter: PlayersSorter
    init(players: [Player]) {
        self.keeper = PlayersKeeper(players: players)
        self.sorter = PlayersSorter()
    }
    func startRound() throws -> [Player] {
        keeper.playersWithCards = dealCards(players: keeper.playersWithCards)
        keeper.playersWithCards = try sortByRoles(players: keeper.playersWithCards)
        //TODO: exchange cards (president-scum; vicePresident-viceScum)
        while keeper.playersWithCards.count > 0 {
            let (winner, players) = try findWinner(players: keeper.playersWithCards)
            keeper.playersWithCards = players
            keeper.kickOffPlayersWithoutCards()
            keeper.playersWithCards = try sortByRoles(players: keeper.playersWithCards, consideringWinner: winner)
        }
        return keeper.playersKickedOffOrder
    }

    func dealCards(players: [Player]) -> [Player] {
        return dealer.dealCards(players: players)
    }

    func sortByRoles(players: [Player]) throws -> [Player] {
        return try sorter.sortByRoles(players: keeper.playersWithCards)
    }

    func findWinner(players: [Player]) throws -> (Player, [Player]) {
        return try OneTrickIterator(players: keeper.playersWithCards).findWinner()
    }

    func sortByRoles(players: [Player], consideringWinner winner: Player) throws -> [Player] {
        return try sorter.sortByRoles(players: keeper.playersWithCards, consideringWinner: winner)
    }
}

class Dealer {
    func dealCards(players: [Player]) -> [Player] {
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
        
        let play = nextPlayer.nextPlay()
        playsPlayers[play] = nextPlayer

        let index = originalPlayers.index(of: nextPlayer)!
        originalPlayers[index] = nextPlayer
        
        return play
    }
}

///Responsible for keeping players in order after being kicked off without cards
struct PlayersKeeper {
    var playersWithCards: [Player]
    private(set) var playersKickedOffOrder: [Player] = []

    init(players: [Player]) {
        self.playersWithCards = players
    }

    ///Removes players without cards on hand and updates @playersKickedOffOrder
    mutating func kickOffPlayersWithoutCards() {
        playersWithCards = playersWithCards.filter {
            guard $0.hand.count > 0 else {
                playersKickedOffOrder.append($0)
                return false
            }
            return true
        }

        if playersWithCards.count == 1  {
            playersKickedOffOrder.append(playersWithCards.removeLast())
        }
    }

}
