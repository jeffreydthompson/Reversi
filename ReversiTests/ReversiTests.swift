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
    var rsut = ReversiBoard()

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
        
        let newBoard = Board()
        newBoard[(.b, ._1)] = .white
        newBoard[(.c, ._1)] = .white
        XCTAssertEqual(newBoard.debugString, testStrSetup)
        
        guard let tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        
        XCTAssertEqual(tstBoard.debugString, testAccumulationString)
        
        var sqs = Array(repeating: Array(repeating: Square.empty, count: 8), count: 8)
        
        sqs[YPos._1.rawValue][XPos.b.rawValue] = .occupied(.white)
        sqs[YPos._1.rawValue][XPos.c.rawValue] = .occupied(.white)
        let rBoard = ReversiBoard(squares: sqs)
        XCTAssertEqual(rBoard.debugString, testStrSetup)
        
        let newRBoard = ReversiBoard(from: testAccumulationString)
        XCTAssertEqual(newRBoard?.debugString, testAccumulationString)
    }
    
    func testMoveLegality() throws {
        guard let tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        XCTAssertFalse(tstBoard.isLegalMove(for: .black, at: (.h, ._4)))
        XCTAssertFalse(tstBoard.isLegalMove(for: .white, at: (.c, ._4)))
        
        guard let rsut = ReversiBoard(from: testAccumulationString) else {
            throw NilError()
        }
        XCTAssertFalse(rsut.checkIsMoveLegal(for: .black, at: .init(x: .h, y: ._4)))
        XCTAssertFalse(rsut.checkIsMoveLegal(for: .white, at: .init(x: .c, y: ._4)))
    }
    
    func testPlacementErrors() throws {
        XCTAssertThrowsError(try sut.playerSet(player: .black, at: (.a, ._1)))
        XCTAssertThrowsError(try sut.playerSet(player: .white, at: (.f, ._5)))
        XCTAssertThrowsError(try sut.playerSet(player: .black, at: (.f, ._6)))
        XCTAssertThrowsError(try sut.playerSet(player: .black, at: (.f, ._4)))
        
        XCTAssertThrowsError(try rsut.set(.black, at: .init(x: .a, y: ._1)))
        XCTAssertThrowsError(try rsut.set(.white, at: .init(x: .f, y: ._5)))
        XCTAssertThrowsError(try rsut.set(.black, at: .init(x: .f, y: ._6)))
        XCTAssertThrowsError(try rsut.set(.black, at: .init(x: .f, y: ._4)))
    }
    
    func testComputerMoveSearch() throws {
        guard let tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        let moves = tstBoard.computerMoveSearch(for: .black)
        let best = moves.keys.map { $0 }.sorted().reversed()
        XCTAssertEqual(3, best.first ?? -1)
        guard let bestMoves = moves[3] else {
            throw NilError()
        }
        XCTAssert(bestMoves.contains(where: { pos in
            pos == (.c, ._4)
        }))
    }
    
    func testPlacementChanges() throws {
        guard let tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        XCTAssertNoThrow(try tstBoard.playerSet(player: .black, at: (.c, ._4)))
        let count = tstBoard.totals
        XCTAssertEqual(count.white, 0)
        XCTAssertEqual(count.black, 11)
        XCTAssertEqual(count.empty, 53)
        print(tstBoard.debugString)
    }
    
    func testSquareCreation() throws {
        let wht = "⚪️"
        let blk = "⚫️"
        let grn = "🟩"
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
