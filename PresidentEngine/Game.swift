//
//  Game.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/19/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import Foundation


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
    var nextPlay: [Card]? {get}
}

class TrickIterator {
    typealias Play = [Card]
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
        
        try validateHasCardsSameRank(play: nextPlay)
        
        if let currentPlay = currentPlay  {
            try validate(nextPlay: nextPlay, whenCurrentPlay: currentPlay)
        }

    }
    
    private func validate(nextPlay: Play, whenCurrentPlay currentPlay: Play) throws {
        
        let hasGreatRank = nextPlay.flatMap { card in currentPlay.map { card > $0 }  }.reduce (true) {$0 && $1}
        guard hasGreatRank else {
            throw Error.lowerRank
        }
        
        let hasSameNumberCards = (nextPlay.count == currentPlay.count)
        
        guard hasSameNumberCards else {
            throw Error.invalidNumberCards
        }
    }
    
    private func validateHasCardsSameRank(play: Play) throws {
        if let firstRank = play.first {
            for rank in play {
                guard firstRank == rank else {
                    throw Error.cardsDifferentRanks
                }
            }
        }
    }
    
    enum Error: Swift.Error {
        case lowerRank
        case invalidNumberCards
        case cardsDifferentRanks
    }
    
}
