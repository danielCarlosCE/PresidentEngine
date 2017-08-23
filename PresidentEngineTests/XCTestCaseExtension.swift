//
//  XCTestCaseExtension.swift
//  PresidentEngine
//
//  Created by Daniel Carlos on 8/23/17.
//  Copyright © 2017 danielcarlosce. All rights reserved.
//

import XCTest

extension XCTestCase {
    func XCTAssertThrows<T, E>(_ expression: @autoclosure () throws -> T,
                         specificError: E) where E: Error, E: Equatable  {
        
        XCTAssertThrowsError(try expression()) { error in
            XCTAssertEqual(error as? E, specificError)
        }
        
    }
}
