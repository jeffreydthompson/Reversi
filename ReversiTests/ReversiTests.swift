//
//  ReversiTests.swift
//  ReversiTests
//
//  Created by Jeffrey Thompson on 11/18/23.
//

import XCTest
@testable import Reversi

struct NilError: Error { }

final class ReversiTests: XCTestCase {
    
    //system under test
    var sut = Board()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut.setupStandardBoard()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDebugPrint() throws {
        let output = sut.debugString
        XCTAssertEqual(output, testStrStandardSetup)
    }
    
    func testInitFromString() throws {
        
        var newBoard = Board()
        newBoard[(.b, ._1)] = .white
        newBoard[(.c, ._1)] = .white
        XCTAssertEqual(newBoard.debugString, testStrSetup)
        
        guard let tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        
        XCTAssertEqual(tstBoard.debugString, testAccumulationString)
    }
    
    func testAccumulation() throws {
        guard var tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        
        let spaces = tstBoard.accumulate(for: .white, heading: .west, from: (.g, ._5))
        XCTAssertNotNil(spaces)
        guard let spaces = spaces else {
            throw NilError()
        }
        XCTAssertEqual(spaces.count, 3)
        XCTAssert(spaces.contains(where: { pos in
            pos == (.f, ._5)
        }))
        
        let allDir = Direction.allCases.flatMap { direction in
            tstBoard.accumulate(for: .black, heading: direction, from: (.c, ._4)) ?? []
        }
        
        XCTAssertEqual(allDir.count, 3)
    }
    
    func testMoveLegality() throws {
        guard var tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        let allDir = Direction.allCases.flatMap { direction in
            tstBoard.accumulate(for: .black, heading: direction, from: (.h, ._4)) ?? []
        }
        XCTAssert(allDir.isEmpty)
    }
    
    func testPlacementErrors() throws {
        XCTAssertThrowsError(try sut.playerSet(player: .black, at: (.a, ._1)))
        XCTAssertThrowsError(try sut.playerSet(player: .white, at: (.f, ._5)))
        XCTAssertThrowsError(try sut.playerSet(player: .black, at: (.f, ._6)))
        XCTAssertThrowsError(try sut.playerSet(player: .black, at: (.f, ._4)))
    }
    
    func testPlacementChanges() throws {
        guard var tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        XCTAssertNoThrow(try tstBoard.playerSet(player: .black, at: (.c, ._4)))
        let count = tstBoard.totals
        XCTAssertEqual(count.white, 0)
        XCTAssertEqual(count.black, 11)
        XCTAssertEqual(count.empty, 53)
        print(tstBoard.debugString)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
