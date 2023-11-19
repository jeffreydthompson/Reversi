//
//  Board.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 11/18/23.
//

import Foundation

enum Player {
    case white, black
    
    var associatedTile: Tile {
        switch self {
        case .white: return .white
        case .black: return .black
        }
    }
}

enum Tile: Equatable {
    case empty, white, black
    var isEmpty: Bool { self == .empty }
}

enum XPos: Int, CaseIterable {
    case a = 0, b, c, d, e, f, g, h
}

enum YPos: Int, CaseIterable {
    case _1 = 0, _2, _3, _4, _5, _6, _7, _8
}

class Board {
    
    enum GameError: Error {
        case illegalMove(String)
        case tileAlreadyOccupied
    }
    
    var tiles: [[Tile]]
    var totals: (white: Int, black: Int, empty: Int) {
        let flat = tiles.flatMap({ $0 })
        let white = flat.filter({ $0 == .white }).count
        let black = flat.filter({ $0 == .black }).count
        let empty = flat.filter({ $0 == .empty }).count
        return (white: white, black: black, empty: empty)
    }
    
    init() {
        tiles = [[Tile]]()
        (0..<8).forEach { y in
            var row = [Tile]()
            (0..<8).forEach { x in
                row.append(.empty)
            }
            tiles.append(row)
        }
    }
    
    func setupStandardBoard() {
        self[.d, ._4] = .white
        self[.e, ._5] = .white
        self[.d, ._5] = .black
        self[.e, ._4] = .black
    }
    
    func playerSet(player: Player, at pos: (XPos, YPos)) throws {
        guard self[pos].isEmpty else { throw GameError.tileAlreadyOccupied }
        let legalTileFlips = getTileFlips(for: player, at: pos)
        if legalTileFlips.isEmpty {
            throw GameError.illegalMove("No legal piece flips")
        }
        
        self[pos] = player.associatedTile
        legalTileFlips.forEach { pos in
            self[pos] = player.associatedTile
        }
    }
    
    func getTileFlips(for player: Player, at pos: (XPos, YPos)) -> [(XPos, YPos)] {
        Direction.allCases.flatMap { direction in
            accumulate(for: player, heading: direction, from: pos) ?? []
        }
    }
    
    func accumulate(
        for player: Player,
        heading direction: Direction,
        from pos: (XPos, YPos)) -> [(XPos, YPos)]? {
        
            guard let nextPos = direction.head(from: pos) else { return nil }
            if self[nextPos].isEmpty { return nil }
            
            // found player's color
            if self[nextPos] == player.associatedTile { return [] }

            // found opponent's color
            guard var result = accumulate(for: player, heading: direction, from: nextPos) else { return nil }
            result.append(nextPos)
            return result
        }
    
    subscript(pos: (XPos, YPos)) -> Tile {
        get { self[pos.0, pos.1] }
        set { self[pos.0, pos.1] = newValue }
    }
    
    subscript(x: XPos, y: YPos) -> Tile {
        get { tiles[y.rawValue][x.rawValue] }
        set { tiles[y.rawValue][x.rawValue] = newValue }
    }
}

enum Direction: CaseIterable {
    case north, northeast, east, southeast, south, southwest, west, northwest
    
    private var vector: (Int, Int) {
        switch self {
        case .north: (0, 1)
        case .northeast: (1, 1)
        case .east: (1, 0)
        case .southeast: (1, -1)
        case .south: (0, -1)
        case .southwest: (-1, -1)
        case .west: (-1, 0)
        case .northwest: (-1, 1)
        }
    }
    
    func head(from pos: (XPos, YPos)) -> (XPos, YPos)? {
        let xVec = pos.0.rawValue + vector.0
        let yVec = pos.1.rawValue + vector.1
        
        if let xPos = XPos(rawValue: xVec),
           let yPos = YPos(rawValue: yVec) {
            return (xPos, yPos)
        } else {
            return nil
        }
    }
}
