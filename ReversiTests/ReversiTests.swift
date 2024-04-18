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
    var sut = Board.defaultBoard()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDebugPrint() throws {
        let output = sut.debugString
        XCTAssertEqual(output, testStrStandardSetup)
    }
    
    func testInitFromString() throws {
        
        var tiles = Board().tiles
        tiles[(.b, ._1)] = .occupied(.white)
        tiles[(.c, ._1)] = .occupied(.white)
        let newBoard = Board(tiles: tiles)
        XCTAssertEqual(newBoard.debugString, testStrSetup)
        
        guard let tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        
        XCTAssertEqual(tstBoard.debugString, testAccumulationString)
    }
    
    func testMoveLegality() throws {
        guard let tstBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        XCTAssertFalse(tstBoard.isLegalMove(for: .black, at: Coordinate(x: .h, y: ._4)))
        XCTAssertFalse(tstBoard.isLegalMove(for: .white, at: Coordinate(x: .c, y: ._4)))
    }
    
    func testPlacementErrors() throws {
        XCTAssertThrowsError(try sut.set(coin: .black, at: Coordinate(x: .a, y: ._1)))
        XCTAssertThrowsError(try sut.set(coin: .white, at: Coordinate(x: .f, y: ._5)))
        XCTAssertThrowsError(try sut.set(coin: .black, at: Coordinate(x: .f, y: ._6)))
        XCTAssertThrowsError(try sut.set(coin: .black, at: Coordinate(x: .f, y: ._4)))
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
            pos == Coordinate(x: .c, y: ._4)
        }))
    }
    
    func testPlacementChanges() throws {
        guard let setupBoard = Board(from: testAccumulationString) else {
            throw NilError()
        }
        let tstBoard = try setupBoard.set(coin: .black, at: Coordinate(x: .c, y: ._4))
        var count = (white: 0, black: 0, empty: 0)
        count.white = tstBoard.tiles.getCount(ofType: .occupied(.white))
        count.black = tstBoard.tiles.getCount(ofType: .occupied(.black))
        count.empty = tstBoard.tiles.getCount(ofType: .empty)
        
        XCTAssertEqual(count.white, 0)
        XCTAssertEqual(count.black, 11)
        XCTAssertEqual(count.empty, 53)
        print(tstBoard.debugString)
    }
    
    func testSetStable() {
        sut = Board(from: testEvalStr)!
        sut = sut.setStable()
        
        XCTAssertEqual(sut.stableCoins.count, 27)
        
        sut = Board(from: testMoveSearch)!
        sut = sut.setStable()
        
        XCTAssertEqual(sut.stableCoins.count, 1)
    }
    
    func testHasLegalMoves() throws {
        let b = Board(from: testEvalStr)!
        XCTAssertFalse(b.hasLegalMoves(for: .white))
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            sut = Board(from: testStables) ?? Board()
            sut = sut.setStable()
        }
    }
}
