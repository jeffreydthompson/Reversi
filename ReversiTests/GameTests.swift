//
//  GameTests.swift
//  ReversiTests
//
//  Created by Jeffrey Thompson on 11/20/23.
//

import XCTest
@testable import Reversi

final class GameTests: XCTestCase {
    
    var sut = Game.uninitiated

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetLegalMoves() throws {
        let b = Board(from: testAccumulationString) ?? Board()
        let moves = getLegalMoves(for: .black(.computer), on: b)
        XCTAssertEqual(moves.count, 6)
        
        let expected = [
            Coordinate(x: .b, y: ._6),
            Coordinate(x: .b, y: ._5),
            Coordinate(x: .c, y: ._4),
            Coordinate(x: .c, y: ._3),
            Coordinate(x: .c, y: ._2),
            Coordinate(x: .d, y: ._2)
        ]
        let s = Set(expected)
        XCTAssertEqual(s, moves)
    }
    
    func testMove() throws {
        let b = Board(from: testAccumulationString) ?? Board()
        let ps = PlayerSet(white: .human, black: .computer)
        
        sut = try makeComputerMove(players: ps, board: b)
        guard case .win(let board, let player) = sut else {
            XCTAssert(false)
            return
        }

        let expectedB = Board(from: testComputerMoveResult) ?? Board()
        XCTAssertEqual(board.debugString, expectedB.debugString)
    }
    
    func testEval() throws {
        let b = Board(from: testEvalStr) ?? Board()
        let ps = PlayerSet(white: .human, black: .computer)
        
        sut = evaluate(board: b, for: ps)
        guard case .inPlay(players: let players, board: let board) = sut else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(players.turn, ps.turn)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension Player: Equatable {
    public static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.coin == rhs.coin
    }
}
