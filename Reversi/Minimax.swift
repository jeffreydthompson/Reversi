//
//  Minimax.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 2/9/24.
//

import Foundation

// special minimax
func minimax(
    maximizingPlayer: ReversiPlayer,
    set: PlayersSet,
    board: ReversiBoard,
    depth: UInt) -> (PlayersSet, Int) {
        
        let result = checkEndTurnGameState(set: set, board: board)
        switch result {
        case .win:
            let score = set.turn == maximizingPlayer ? Int.max : Int.min
            return (set, score)
        case .tie: return (set, 0)
        case .inPlay:
            
            
            
            
            break
        }
        
        return (set, 0)
    }

enum GameResult {
    case win, tie, inPlay
}

func checkEndTurnGameState(
    set: PlayersSet,
    board: ReversiBoard) -> GameResult {
        
        let opponentPositions = board.getPositionsFor(square: .occupied(set.turnOpponent.coin))
        if opponentPositions.isEmpty { return .win }
        if board.checkCanMove(for: set.turnOpponent.coin) { return .inPlay }
        if board.checkCanMove(for: set.turn.coin) { return .inPlay }
        
        let turnPositions = board.getPositionsFor(square: .occupied(set.turn.coin))
        
        if turnPositions.count > opponentPositions.count {
            return .win
        }
        
        return .tie
    }
