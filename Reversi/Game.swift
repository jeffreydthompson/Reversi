//
//  Game.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 11/19/23.
//

import Foundation

enum PlayerType {
    case human, computer
}

enum Player {
    case white(PlayerType)
    case black(PlayerType)
    
    var type: PlayerType {
        switch self {
        case .black(let type), .white(let type): return type
        }
    }
    
    var coin: Coin {
        switch self {
        case .white: return .white
        case .black: return .black
        }
    }
}

struct PlayerSet {
    let white: Player
    let black: Player
    let turn: Player
    
    init(white wType: PlayerType, black bType: PlayerType) {
        self.white = .white(wType)
        self.black = .black(bType)
        self.turn = self.black
    }
    
    private init(white: Player, black: Player, turn: Player) {
        self.white = white
        self.black = black
        self.turn = turn
    }
    
    func nextTurn() -> PlayerSet {
        switch turn {
        case .white:
            return PlayerSet(white: white, black: black, turn: black)
        case .black:
            return PlayerSet(white: white, black: black, turn: white)
        }
    }
}

enum Game {
    case uninitiated
    case inPlay(players: PlayerSet, board: Board)
    case tie(board: Board)
    case win(board: Board, player: Player)
    case error(Error)
}

func evaluate(
    board b: Board,
    for ps: PlayerSet
) -> Game {
    
    func evalEndGame() -> Game {
        let blk = b.tiles.getCount(ofType: .occupied(.black))
        let wht = b.tiles.getCount(ofType: .occupied(.white))
        if wht == blk { return .tie(board: b) }
        if wht > blk {
            return .win(board: b, player: ps.white)
        } else {
            return .win(board: b, player: ps.black)
        }
    }
    
    let empties = b.tiles.getCount(ofType: .empty)
    if empties == 0 {
        // end condition
        return evalEndGame()
    }
    
    let next = ps.nextTurn()
    if b.hasLegalMoves(for: next.turn.coin) {
        return .inPlay(players: next, board: b)
    }
    if b.hasLegalMoves(for: ps.turn.coin) {
        return .inPlay(players: ps, board: b)
    }
    return evalEndGame()
}

func makeHumanMove(
    to c: Coordinate,
    players: PlayerSet,
    board: Board) -> Game {
        guard let b = try? board.set(coin: players.turn.coin, at: c) else { return .inPlay(players: players, board: board) }
        return evaluate(board: b, for: players)
    }

func makeComputerMove(players: PlayerSet, board: Board) throws -> Game {
    
    let moveCadidates = getLegalMoves(for: players.turn, on: board)
    guard !moveCadidates.isEmpty else {
        return .inPlay(players: players, board: board)
    }
    var bestScore = SCORE_MIN
    var bestMove: Coordinate?
    for move in moveCadidates {
        let score = try minimax(depth: 0, moveCandidate: move, maximizingPlayer: players.turn.coin, players: players, on: board)
        if score > bestScore {
            bestScore = score
            bestMove = move
        }
    }
    
    let best = bestMove ?? moveCadidates.first!
    let b = try board.set(coin: players.turn.coin, at: best)
    return evaluate(board: b, for: players)
}

let MMAX_DEPTH_LIMIT = 3
func minimax(
    depth: UInt8,
    moveCandidate coordinate: Coordinate,
    maximizingPlayer mp: Coin,
    players ps: PlayerSet,
    on b: Board) throws -> Int {
        
        var multiplier = ps.turn.coin == mp ? 1 : -1
        
        let board = try b
            .set(coin: ps.turn.coin, at: coordinate)
            .setStable()
        
        let score = Heuristics.score(board: board, for: ps.turn)
        if score == SCORE_MAX {
            return ps.turn.coin == mp ? SCORE_MAX : SCORE_MIN
        }
        if depth == MMAX_DEPTH_LIMIT { return score * multiplier }
        
        let nextTurn = ps.nextTurn()
        let targetScore = nextTurn.turn.coin == mp ? SCORE_MAX : SCORE_MIN
        var bestScore = nextTurn.turn.coin == mp ? SCORE_MIN : SCORE_MAX
        
        let legalMoves = getLegalMoves(for: nextTurn.turn, on: board)
        let filter: (Int, Int) -> Int = nextTurn.turn.coin == mp ? { $0 > $1 ? $0 : $1} : { $0 < $1 ? $0 : $1 }
        
        for move in legalMoves {
            let someScore = try minimax(depth: depth + 1, moveCandidate: move, maximizingPlayer: mp, players: nextTurn, on: board)
            if someScore == targetScore { return targetScore }
            bestScore = filter(someScore, bestScore)
        }
        
        return bestScore
    }

func getLegalMoves(for player: Player, on board: Board) -> Set<Coordinate> {
    let empties = Coordinate.all().compactMap { c in
        board[c] == .empty ? c : nil
    }
    let legalMoves = empties.filter { c in
        board.isLegalMove(for: player.coin, at: c)
    }
    return Set(legalMoves)
}

/*
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
    let human: Player
    
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
        self.board.reset()
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
*/
