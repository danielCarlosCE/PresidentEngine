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
        var result: String?
        let sut = makeSut(forPlays: [("p1", "4♣︎")])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result, "4♣︎")
    }
    
    func test_startTrick_withTwoPlays_reachesLastPlay() {
        var result: String?
        let sut = makeSut(forPlays: [("p1", "3♣︎"), ("p2", "4♣︎")])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result!, "4♣︎")
    }
    
    func test_startTrick_withoutPlays_returnsNoPlay() {
        var result: String?
        let sut = makeSut(forPlays: [])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertNil(result)
    }
    
    func test_startTrick_withSetCardsPlays_returnsResult() {
        var result: String?
        let sut = makeSut(forPlays: [("p1", "4♣︎,4♥︎"), ("p2", "8♣︎,8♣︎")])
        
        try! sut.startTrick { result = $0 }
        
        XCTAssertEqual(result, "8♣︎,8♣︎")
    }
    
    func test_startTrick_withLowerValuePlay_throwsError() {
        let sut = makeSut(forPlays: [("p1", "6♣︎"), ("p2", "4♣︎")])
        
        XCTAssertThrows(try sut.startTrick {_ in }, specificError: TrickIterator.Error.lowerValue)
    }
    
    func test_startTrick_withWrongNumberCardsPlay_throwsError() {
        let sut = makeSut(forPlays: [("p1", "6♣︎"), ("p2", "8♣︎,8♦︎")])
        
        XCTAssertThrows(try sut.startTrick {_ in }, specificError: TrickIterator.Error.invalidNumberCards)
    }
    
    func test_startTrick_withCardsDifferentValuesPlay_throwsError() {
        let sut = makeSut(forPlays: [("p1", "6♣︎, 7♣︎")])
        
        XCTAssertThrows(try sut.startTrick {_ in }, specificError: TrickIterator.Error.cardsDifferentValues)
    }

    
    //MARK: private
    
    private func makeSut(forPlays plays: [(String, String)]) -> TrickIterator {
        let mockPlayOrderer = MockPlayOrderer(plays: plays)
        return TrickIterator(playOrderer: mockPlayOrderer)
    }
    
    // Mark: Mocks
    
    class MockPlayOrderer: PlayOrderer {
        private var nextIndex = 0
        private var plays: [(String, String)]
        
        init(plays: [(String, String)]) {
            self.plays = plays
        }
        
        var nextPlay: String? {
            guard plays.count > nextIndex else { return nil }
            let currentIndex = nextIndex
            nextIndex += 1
            return plays[currentIndex].1
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
