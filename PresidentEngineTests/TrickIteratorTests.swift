//
//  TrickIterator.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/19/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import XCTest
@testable import PresidentEngine

class TrickIteratorTests: XCTestCase {
    
    func test_startTrick_withOnePlay_returnsResult() {
        var result: Play?
        let sut = makeSut(forPlays: [["4"]])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result!, ["4"])
    }
    
    func test_startTrick_withTwoPlays_reachesLastPlay() {
        var result: Play?
        let sut = makeSut(forPlays: [["3"], ["4"]])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result!, ["4"])
    }
    
    func test_startTrick_withoutPlays_throwsError() {
        let sut = makeSut(forPlays: [])
                
        XCTAssertThrows(try sut.startTrick {_ in }, specificError: TrickIterator.Error.nonePlaysFromOrderer)
    }
    
    func test_startTrick_withSetCardsPlays_returnsResult() {
        var result: Play?
        let sut = makeSut(forPlays: [["4","4"], ["8","8"]])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result!, ["8","8"])
    }
    
    func test_startTrick_considersTwoAcesGreatestRanks() {
        var result: Play?
        let sut = makeSut(forPlays: [["3"],["4"],["5"],["6"],["7"],["8"],["9"],["10"],["J"],["Q"],["K"],["A"],["2"]])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result!, ["2"])
    }
    
    func test_startTrick_withLowerRankPlay_throwsError() {
        let sut = makeSut(forPlays: [["6"], ["4"]])
        
        XCTAssertThrows(try sut.startTrick {_ in }, specificError: TrickIterator.Error.lowerRank)
    }
    
    func test_startTrick_withWrongNumberCardsPlay_throwsError() {
        let sut = makeSut(forPlays: [["6"], ["8","8"]])
        
        XCTAssertThrows(try sut.startTrick {_ in }, specificError: TrickIterator.Error.invalidNumberCards)
    }
    
    func test_startTrick_withCardsDifferentRanksPlay_throwsError() {
        let sut = makeSut(forPlays: [["6", "7"]])
        
        XCTAssertThrows(try sut.startTrick {_ in }, specificError: TrickIterator.Error.cardsDifferentRanks)
    }

}

extension TrickIteratorTests {
    private func makeSut(forPlays plays: [Play]) -> TrickIterator {
        let mockPlayOrderer = MockPlayOrderer(plays: plays)
        return TrickIterator(playOrderer: mockPlayOrderer)
    }
    
    class MockPlayOrderer: PlayOrderer {
        private var plays: [Play]
        
        init(plays: [Play]) {
            self.plays = plays
        }
        
        var nextPlay: Play? {
            guard plays.count > 0 else { return nil }
            return plays.removeFirst()
        }
    }
}
