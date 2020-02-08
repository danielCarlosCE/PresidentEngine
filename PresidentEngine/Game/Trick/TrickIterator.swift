//
//  TrickIterator.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

/**
 Navigates through a trick
 
 Does not relate to players. Only knows about *Plays*
 */
class TrickIterator {
    private let playOrderer: PlayOrderer
    
    init(playOrderer: PlayOrderer) {
        self.playOrderer = playOrderer
    }
    
    /**
     Goes around asking for next plays, until there's none left
     
     Each play is validated through a set of rules.
     
     The last valid play with cards is considered the winner.
     
     The trick ends when `nextPlay` is nil.
     
     - parameter resultCallback: called when trick ends
     - parameter play: winner play
     */
    func startTrick(resultCallback: (_ play: Play) -> Void) throws {
        var currentPlay: [Card]?
        
        //TODO: first play can't skip
        
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
}

extension TrickIterator {
    enum Error: Swift.Error {
        case lowerRank
        case invalidNumberCards
        case cardsDifferentRanks
        case nonePlaysFromOrderer
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
}
