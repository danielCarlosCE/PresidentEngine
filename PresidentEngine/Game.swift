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
            let hasGreatRank = play.flatMap { card in currentPlay.map { card > $0 }  }.reduce (true) {$0 && $1}
            guard hasGreatRank else {
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

