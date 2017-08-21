//
//  Game.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/19/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import Foundation

protocol PlayOrderer {
    var nextPlay: [String]? {get}
}

class TrickIterator {
    typealias Play = [String]
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
        
        try validateHasCardsSameValue(play: nextPlay)
        
        if let currentPlay = currentPlay  {
            try validate(nextPlay: nextPlay, whenCurrentPlay: currentPlay)
        }

    }
    
    private func validate(nextPlay: Play, whenCurrentPlay currentPlay: Play) throws {
        
        let hasGreatRank = nextPlay.flatMap { card in currentPlay.map { card > $0 }  }.reduce (true) {$0 && $1}
        guard hasGreatRank else {
            throw Error.lowerValue
        }
        
        let hasSameNumberCards = (nextPlay.count == currentPlay.count)
        
        guard hasSameNumberCards else {
            throw Error.invalidNumberCards
        }
    }
    
    private func validateHasCardsSameValue(play: Play) throws {
        let values = play.map {
            $0.replacingOccurrences(of: "♣︎", with: "")
                .replacingOccurrences(of: "♠︎", with: "")
                .replacingOccurrences(of: "♥︎", with: "")
                .replacingOccurrences(of: "♦︎", with: "")
        }
        if let firstValue = values.first {
            for value in values {
                guard firstValue == value else {
                    throw Error.cardsDifferentValues
                }
            }
        }
    }
    
    enum Error: Swift.Error {
        case lowerValue
        case invalidNumberCards
        case cardsDifferentValues
    }
    
}
