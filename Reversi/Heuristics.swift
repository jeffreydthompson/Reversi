//
//  Heuristics.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 2/9/24.
//

import Foundation

struct Heuristics {
    static let weights: [Coordinate: Int] = {
        var w = [Coordinate: Int]()
        for x in XPos.allCases {
            for y in YPos.allCases {
                w[.init(x: x, y: y)] = _weights[x.rawValue][y.rawValue]
            }
        }
        return w
    }()
    
    private static let _weights: [[Int]] = [
        [4, -3, 2, 2, 2, 2, -3, 4],
        [-3,-4,-1,-1,-1,-1, -4,-3],
        [2, -1, 1, 0, 0, 1, -1, 2],
        [2, -1, 0, 1, 1, 0, -1, 2],
        [2, -1, 0, 1, 1, 0, -1, 2],
        [2, -1, 1, 0, 0, 1, -1, 2],
        [-3,-4,-1,-1,-1,-1, -4,-3],
        [4, -3, 2, 2, 2, 2, -3, 4],
    ]
    
    static func isStable(_ coin: Coin,
                         at coordinate: Coordinate,
                         on board: ReversiBoard) -> Bool {
        
        let initialPass = Direction.allCases.reduce(into: [Direction]()) { partialResult, direction in
            if let next = direction.next(from: coordinate) {
                if board.stableSquares.contains(coordinate) {
                    partialResult.append(direction)
                }
            } else {
                partialResult.append(direction)
            }
        }
        
        return initialPass.twoSideStability
    }
}
