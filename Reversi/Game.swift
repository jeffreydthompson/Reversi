//
//  Game.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 11/19/23.
//

import Foundation

@Observable
class Game {
    
    enum GameError: Error {
        case noMovesLeft
    }
    
    enum GameState {
        case normal
        case error(Error)
        case end(winner: Player)
    }
    
    let board: Board
    var state: GameState = .normal
    
    var turn: Player
    
    var human: Player
    
    init(board: Board = Board(), human: Player = .black) {
        self.board = board
        self.board.setupStandardBoard()
        self.turn = .black
        self.human = human
    }
    
    init(customBoard: Board) {
        self.board = customBoard
        self.turn = .black
        self.human = .black
    }
    
    func reset() {
        self.board.setupStandardBoard()
        self.turn = .black
        asyncSetState(.normal)
    }
    
    func queryTotals(noMovesLeft: Bool = false) {
        let totals = board.totals
        if totals.empty == 0 || noMovesLeft {
            let winner: Player = (totals.black > totals.white) ? .black : .white
            asyncSetState(.end(winner: winner))
        }
        
        if totals.black == 0 { asyncSetState(.end(winner: .white)) }
        if totals.white == 0 { asyncSetState(.end(winner: .black)) }
        
    }
    
    func nextTurn() {
        turn = turn.toggle
        let possibleMoves = board.computerMoveSearch(for: turn)
        if possibleMoves.isEmpty {
            turn = turn.toggle
            let nextPossibleMoves = board.computerMoveSearch(for: turn)
            if nextPossibleMoves.isEmpty {
                queryTotals(noMovesLeft: true)
            }
        }
    }
    
    func moveIsLegal(at pos: (XPos, YPos)) -> Bool {
        board.isLegalMove(for: turn, at: pos)
    }
    
    func executeMove(at pos: (XPos, YPos)) {
        do {
            try board.playerSet(player: turn, at: pos)
            queryTotals()
            nextTurn()
            if turn != human {
                computerCalculateMove()
            }
        } catch {
            asyncSetState(.error(error))
        }
    }
    
    func computerCalculateMove() {
        let moves = board.computerMoveSearch(for: turn)
        guard let bestKey = moves.keys.map({$0}).sorted().reversed().first,
            let bestMoves = moves[bestKey] else {

            queryTotals(noMovesLeft: true)
            return
        }
        
        let bestMove = sortBest(positions: bestMoves).first!
        executeMove(at: bestMove)
    }
    
    func dismissError() {
        asyncSetState(.normal)
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
    
    private func asyncSetState(_ newState: GameState) {
        DispatchQueue.main.async {
            self.state = newState
        }
    }
}

enum MoveError: Error {
    case alreadyOccupied
    case illegalMove
}

enum ReversiGame {
    case unitialized
    case inPlay(set: PlayersSet, board: ReversiBoard)
    case tie(board: ReversiBoard)
    case win(player: ReversiPlayer, board: ReversiBoard)
    
    static func computerMove(
        set: PlayersSet,
        on board: ReversiBoard) -> ReversiGame {
        
            return .unitialized
        }
    
    static func humanMove(
        to coordinate: Coordinate,
        set: PlayersSet,
        on board: ReversiBoard) throws -> ReversiGame {
            let copyBoard = try board.set(set.turn.coin, at: coordinate)
            return ReversiGame.processMove(for: set, on: copyBoard)
        }
    
    static func processMove(
        for set: PlayersSet,
        on board: ReversiBoard) -> ReversiGame {
            
            if board.checkCanMove(for: set.turnOpponent.coin) {
                let copySet = set.switchTurn()
                return .inPlay(set: copySet, board: board)
            } else if board.checkCanMove(for: set.turn.coin) {
                return .inPlay(set: set, board: board)
            } else { // then end condition met.
                let turnPositions = board.getPositionsFor(square: .occupied(set.turn.coin))
                let opponentPositions = board.getPositionsFor(square: .occupied(set.turnOpponent.coin))
                
                if turnPositions.count > opponentPositions.count {
                    return .win(player: set.turn, board: board)
                } else if turnPositions.count < opponentPositions.count {
                    return .win(player: set.turnOpponent, board: board)
                } else {
                    return .tie(board: board)
                }
            }
        }
}

@Observable
class ReversiGameViewModel {
    var state = ReversiGame.unitialized
    
    func move(
        to coordinate: Coordinate,
        for set: PlayersSet,
        on board: ReversiBoard) throws {
            print(coordinate)
            do {
                state = try ReversiGame
                    .humanMove(to: coordinate, set: set, on: board)
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    
    func initializeGame(
        white wType: PlayerType,
        black bType: PlayerType) {
            let set = PlayersSet.blackTurn(black: .black(bType), white: .white(wType))
            let board = ReversiBoard()
            state = .inPlay(set: set, board: board)
        }
}
