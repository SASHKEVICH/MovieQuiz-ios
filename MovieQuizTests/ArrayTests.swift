//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Александр Бекренев on 08.12.2022.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() {
        let array = [1, 2, 5, 12, 2523]
        
        let value = array[safe: 2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 5)
    }
    
    func testGetValueOutOfRange() {
        let array = [1, 2, 5, 12, 2523]
        
        let value = array[safe: 20]
        
        XCTAssertNil(value)
    }
}
