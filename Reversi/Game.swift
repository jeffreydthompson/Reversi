//
//  Game.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 11/19/23.
//

import Foundation

class Game {
    
    enum GameError: Error {
        case noMovesLeft
    }
    
    let board: Board
    let playerWhite: Player = .white
    let playerBlack: Player = .black
    var winner: Player? = nil
    
    var turn: Player
    
    init(board: Board = Board()) {
        self.board = board
        self.board.setupStandardBoard()
        self.turn = playerBlack
    }
    
    init(customBoard: Board) {
        self.board = customBoard
        self.turn = playerBlack
    }
    
    func queryTotals() {
        let totals = board.totals
        if totals.empty == 0 {
            winner = (totals.black > totals.white) ? .black : .white
        }
    }
    
    func nextTurn() {
        turn = (turn == .black) ? .white : .black
    }
    
    func moveIsLegal(at pos: (XPos, YPos)) -> Bool {
        board.isLegalMove(for: turn, at: pos)
    }
    
    func executeMove(at pos: (XPos, YPos)) throws {
        try board.playerSet(player: turn, at: pos)
    }
    
    func computerCalculateMove() throws {
        let moves = board.computerMoveSearch(for: turn)
        guard let bestKey = moves.keys.map({$0}).sorted().reversed().first,
            let bestMoves = moves[bestKey] else {
            throw GameError.noMovesLeft
        }
        
        let bestMove = sortBest(positions: bestMoves).first!
        try executeMove(at: bestMove)
    }
    
    private func sortBest(positions: [(XPos, YPos)]) -> [(XPos, YPos)] {
        positions.sorted {
            edgeCornerScore(position: $0) > edgeCornerScore(position: $1)
        }
    }
    
    private func edgeCornerScore(position: (XPos, YPos)) -> Int {
        let x = position.0.isEdge ? 1 : 0
        let y = position.1.isEdge ? 1 : 0
        return x + y
    }
}
