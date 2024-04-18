//
//  Heuristics.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 4/17/24.
//

import Foundation

// to prevent overflows of Int.min * -1
let SCORE_MAX = 999_999_999
let SCORE_MIN = -999_999_999

enum MoveResult {
    case win(Player)
    case tie
    case inPlay
}

enum Heuristics {
    
    //scoring source: https://courses.cs.washington.edu/courses/cse573/04au/Project/mini1/RUSSIA/Final_Paper.pdf
    static let locationValue: [[Int]] = [
        [4, -3, 2, 2, 2, 2, -3, 4],
        [-3, -4, -1, -1, -1, -1, -4, -3],
        [2, -1, 1, 0, 0, 1, -1, 2],
        [2, -1, 0, 1, 1, 0, -1, 2],
        [2, -1, 0, 1, 1, 0, -1, 2],
        [2, -1, 1, 0, 0, 1, -1, 2],
        [-3, -4, -1, -1, -1, -1, -4, -3],
        [4, -3, 2, 2, 2, 2, -3, 4],
    ]
    
    static func score(board: Board, for player: Player) -> Int {
        
        let count = countTiles(board: board)
        let playerTotal = count[.occupied(player.coin), default: 0]
        let opponentTotal = count[.occupied(player.coin.opposite), default: 0]
        let emptyTotal = count[.empty, default: 0]
        
        //win conditions
        if opponentTotal == 0 { return SCORE_MAX }
        if emptyTotal == 0 {
            if playerTotal > opponentTotal {
                return SCORE_MAX
            } else if playerTotal == opponentTotal {
                return 0
            } else {
                return SCORE_MIN
            }
        }
        
        var score = 0
        //TODO: scoring
        // if is stable - scored at 4
        let stableCount = countStables(board: board)
        score += (stableCount[player.coin, default: 0] * 4)
        score -= (stableCount[player.coin.opposite, default: 0] * 4)
        // if not stable - scored at locationValue
        let unstable = Coordinate.all().subtracting(board.stableCoins)
        unstable.forEach { c in
            if board[c] == .occupied(player.coin) {
                score += locationValue[c]
            }
            if board[c] == .occupied(player.coin.opposite) {
                score -= locationValue[c]
            }
        }
        
        score += playerTotal
        score -= opponentTotal

        return score
    }
    
    static func countStables(board: Board) -> [Coin: Int] {
        var count = [Coin: Int]()
            
        let stableCoins = board.stableCoins
        count[.white] = stableCoins.filter({
            board.tiles[$0] == .occupied(.white)
        }).count
        count[.black] = stableCoins.filter({
            board.tiles[$0] == .occupied(.black)
        }).count
        
        return count
    }
    
    static func countTiles(board: Board) -> [Tile: Int] {
        var count = [Tile: Int]()
        
        count[.empty] = board.tiles.getCount(ofType: .empty)
        count[.occupied(.black)] = board.tiles.getCount(ofType: .occupied(.black))
        count[.occupied(.white)] = board.tiles.getCount(ofType: .occupied(.white))
        
        return count
    }
}

extension Array where Element == Array<Int> {
    subscript(_ c: Coordinate) -> Int {
        get { self[c.x.rawValue][c.y.rawValue] }
    }
}
