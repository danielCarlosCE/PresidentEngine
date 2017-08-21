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
        var result: [String]?
        let sut = makeSut(forPlays: [["4"]])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result!, ["4"])
    }
    
    func test_startTrick_withTwoPlays_reachesLastPlay() {
        var result: [String]?
        let sut = makeSut(forPlays: [["3"], ["4"]])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result!, ["4"])
    }
    
    func test_startTrick_withoutPlays_returnsNoPlay() {
        var result: [String]?
        let sut = makeSut(forPlays: [])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertNil(result)
    }
    
    func test_startTrick_withSetCardsPlays_returnsResult() {
        var result: [String]?
        let sut = makeSut(forPlays: [["4","4"], ["8","8"]])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result!, ["8","8"])
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

    
    //MARK: private
    
    private func makeSut(forPlays plays: [[String]]) -> TrickIterator {
        let mockPlayOrderer = MockPlayOrderer(plays: plays)
        return TrickIterator(playOrderer: mockPlayOrderer)
    }
    
    // Mark: Mocks
    
    class MockPlayOrderer: PlayOrderer {
        private var nextIndex = 0
        private var plays: [[String]]
        
        init(plays: [[String]]) {
            self.plays = plays
        }
        
        var nextPlay: [String]? {
            guard plays.count > nextIndex else { return nil }
            let currentIndex = nextIndex
            nextIndex += 1
            return plays[currentIndex]
        }
    }

}

private extension XCTestCase {
    func XCTAssertThrows<T, E>(_ expression: @autoclosure () throws -> T,
                                 specificError: E) where E: Error, E: Equatable  {
        
        XCTAssertThrowsError(try expression()) { error in
            XCTAssertEqual(error as? E, specificError)
        }
        
    }
}
