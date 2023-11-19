//
//  GameTests.swift
//  ReversiTests
//
//  Created by Jeffrey Thompson on 11/20/23.
//

import XCTest
@testable import Reversi

final class GameTests: XCTestCase {
    
    var sut = Game(customBoard: Board(from: testAccumulationString)!)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testComputerMove() throws {
        sut.turn = .black
        try sut.computerCalculateMove()
        let count = sut.board.totals
        XCTAssertEqual(count.white, 0)
        XCTAssertEqual(count.black, 11)
        XCTAssertEqual(count.empty, 53)
        print(sut.board.debugString)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
