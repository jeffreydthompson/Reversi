//
//  Board.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 11/18/23.
//

import Foundation

enum Coin: Equatable {
    case black, white
    var opposite: Coin {
        self == .white ? .black : .white
    }
}

enum Tile: Equatable, Hashable {
    case occupied(Coin)
    case empty
}

enum XPos: Int, CaseIterable, Identifiable {
    case a = 0, b, c, d, e, f, g, h
    var id: Int { rawValue }
    var isEdge: Bool { self == .a || self == .h }
}

enum YPos: Int, CaseIterable, Identifiable {
    case _1 = 0, _2, _3, _4, _5, _6, _7, _8
    var id: Int { rawValue }
    var isEdge: Bool { self == ._1 || self == ._8 }
}

struct Coordinate: Equatable, Hashable {
    let x: XPos
    let y: YPos
    
    static func getColumn(_ x: XPos) -> [Coordinate] {
        YPos.allCases.map({ Coordinate(x: x, y: $0)})
    }
    
    static func getRow(_ y: YPos) -> [Coordinate] {
        XPos.allCases.map({ Coordinate(x: $0, y: y)})
    }
    
    static func all() -> Set<Coordinate> {
        let all = XPos.allCases.flatMap({ x in
            YPos.allCases.map({ y in
                Coordinate(x: x, y: y)
            })
        })
        return Set(all)
    }
}

struct Board {
    
    enum GameError: Error {
        case illegalMove(String)
        case tileAlreadyOccupied
    }
    
    let tiles: [[Tile]]
    let stableCoins: Set<Coordinate>
    
    init() {
        tiles = (0..<8).map { (_) -> [Tile] in 
            Array<Tile>(repeating: .empty, count: 8) }
        stableCoins = Set<Coordinate>()
    }
    
    init(tiles: [[Tile]], 
         stableCoins: Set<Coordinate> = .init()) {
            self.tiles = tiles
            self.stableCoins = stableCoins
        }
    
    static func defaultBoard() -> Board {
        var tiles = (0..<8).map { (_) -> [Tile] in
            Array<Tile>(repeating: .empty, count: 8) }
        tiles[.d, ._4] = .occupied(.white)
        tiles[.e, ._5] = .occupied(.white)
        tiles[.d, ._5] = .occupied(.black)
        tiles[.e, ._4] = .occupied(.black)
        return Board(tiles: tiles)
    }
    
    func set(coin: Coin, at pos: Coordinate) throws -> Board {
        guard tiles[pos] == .empty else { throw GameError.tileAlreadyOccupied }
        let legalTileFlips = getTileFlips(for: coin, at: pos)
        if legalTileFlips.isEmpty {
            throw GameError.illegalMove("No legal piece flips")
        }
        
        var copyTiles = tiles
        copyTiles[pos] = .occupied(coin)
        legalTileFlips.forEach { pos in
            copyTiles[pos] = .occupied(coin)
        }
        return Board(tiles: copyTiles)
    }
    
    func hasLegalMoves(for coin: Coin) -> Bool {
        Coordinate.all().reduce(into: false) { b, c in
            b = b || isLegalMove(for: coin, at: c)
        }
    }
    
    func isLegalMove(for coin: Coin, at pos: Coordinate) -> Bool {
        guard self[pos] == .empty else { return false }
        return !getTileFlips(for: coin, at: pos).isEmpty
    }
    
    func computerMoveSearch(for coin: Coin) -> [Int: [Coordinate]] {
        var score = [Int: [Coordinate]]()
        for x in XPos.allCases {
            for y in YPos.allCases {
                guard tiles[x,y] == .empty else { continue }
                let result = getTileFlips(for: coin, at: Coordinate(x: x, y: y))
                if !result.isEmpty {
                    score[result.count, default: []].append(Coordinate(x: x, y: y))
                }
            }
        }
        return score
    }
    
    private func getTileFlips(for coin: Coin, at pos: Coordinate) -> [Coordinate] {
        Direction.allCases.flatMap { direction in
            accumulate(for: coin, heading: direction, from: pos) ?? []
        }
    }
    
    private func accumulate(
        for coin: Coin,
        heading direction: Direction,
        from pos: Coordinate) -> [Coordinate]? {
        
            guard let nextPos = direction.next(from: pos) else { return nil }
            if tiles[nextPos] == .empty { return nil }
            
            // found player's color
            if tiles[nextPos] == .occupied(coin) { return [] }

            // found opponent's color
            guard var result = accumulate(for: coin, heading: direction, from: nextPos) else { return nil }
            result.append(nextPos)
            return result
        }
    
    private func getStableOrthogonal() -> Set<Coordinate> {
        var newStables = Set<Coordinate>()
        
        func setRowCol<T: RawRepresentable>(
            dim: T.Type,
            tGetter tG: (T) -> [Tile],
            cGetter cG: (T) -> [Coordinate],
            positiveVector: Bool) -> Set<Coordinate> {
                var index = positiveVector ? 0 : 7
                let vector = positiveVector ? 1 : -1
                var result = Set<Coordinate>()
                loop: while true {
                    guard let i = index as? T.RawValue,
                          let t = T(rawValue: i) else {
                        break loop
                    }
                    if tG(t).allOccupied {
                        let line = cG(t)
                        result.formUnion(line)
                        index += (vector * 1)
                    } else {
                        break loop
                    }
                }
                return result
            }
        
        let leading = setRowCol(dim: XPos.self, tGetter: tiles.getColumn(_:), cGetter: Coordinate.getColumn(_:), positiveVector: true)
        let trailing = setRowCol(dim: XPos.self, tGetter: tiles.getColumn(_:), cGetter: Coordinate.getColumn(_:), positiveVector: false)
        let top = setRowCol(dim: YPos.self, tGetter: tiles.getRow(_:), cGetter: Coordinate.getRow(_:), positiveVector: true)
        let bottom = setRowCol(dim: YPos.self, tGetter: tiles.getRow(_:), cGetter: Coordinate.getRow(_:), positiveVector: false)
        newStables.formUnion(leading)
        newStables.formUnion(trailing)
        newStables.formUnion(top)
        newStables.formUnion(bottom)
        
        return newStables
    }
    
    func setStable(depth: Int = 0) -> Board {
        
        if depth >= 4 { return self }
        var newStables = Set<Coordinate>()

        if depth == 0 {
            newStables.formUnion(getStableOrthogonal())
        }
        
        let corners: [Direction: Coordinate] = [
            .northeast: Coordinate(x: .init(rawValue: depth)!, y: .init(rawValue: depth)!),
            .southeast: Coordinate(x: .init(rawValue: depth)!, y: .init(rawValue: 7 - depth)!),
            .southwest: Coordinate(x: .init(rawValue: 7 - depth)!, y: .init(rawValue: 7 - depth)!),
            .northwest: Coordinate(x: .init(rawValue: 7 - depth)!, y: .init(rawValue: depth)!)
        ]
        
        func isStable(
            direction d: Direction,
            coordinate c: Coordinate) -> Bool {
                
                if stableCoins.contains(c) { return true }
                if newStables.contains(c) { return true }
                if self[c] == .empty { return false }
                
                let opposites = [
                    d.opposite,
                    d.opposite.legs.left,
                    d.opposite.legs.right
                ]
                
                let oppositeCs = opposites.compactMap { $0.next(from:c) }
                if oppositeCs.isEmpty { return true }
                if oppositeCs.allSatisfy({
                    newStables.contains($0) || tiles[$0] == tiles[c]
                }) {
                    return true
                }
                return false
            }
        
        for (direction, startingCoordinate) in corners {
            let legs = direction.legs

            guard isStable(direction: direction, coordinate: startingCoordinate) else {
                continue
            }
            
            newStables.insert(startingCoordinate)
            
            var lCoordinate = startingCoordinate
            var rCoordinate = startingCoordinate
            
            leftLoop: while true {
                guard let nextC = legs.left.next(from: lCoordinate) else {
                    break leftLoop
                }
                lCoordinate = nextC
                if newStables.contains(lCoordinate) { break leftLoop }
                guard isStable(direction: legs.left, coordinate: lCoordinate) else {
                    break leftLoop
                }
                newStables.insert(lCoordinate)
            }
            
            rightLoop: while true {
                guard let nextC = legs.right.next(from: rCoordinate) else {
                    break rightLoop
                }
                rCoordinate = nextC
                if newStables.contains(rCoordinate) { break rightLoop }
                guard isStable(direction: legs.right, coordinate: rCoordinate) else {
                    break rightLoop
                }
                newStables.insert(rCoordinate)
            }
        }
        
        if newStables.isEmpty { return self }
        let mergedStables = stableCoins.union(newStables)
        return Board(tiles: tiles, stableCoins: mergedStables)
            .setStable(depth: depth + 1)
    }
    
    subscript(_ c: Coordinate) -> Tile {
        get { tiles[c] }
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
    
    var opposite: Direction {
        switch self {
        case .north: return .south
        case .northeast: return .southwest
        case .east: return .west
        case .southeast: return .northwest
        case .south: return .north
        case .southwest: return .northeast
        case .west: return .east
        case .northwest: return .southeast
        }
    }
    
    var legs: (left: Direction, right: Direction) {
        switch self {
        case .north: return (.northwest, .northeast)
        case .northeast: return (.north, .east)
        case .east: return (.northeast, .southeast)
        case .southeast: return (.east, .south)
        case .south: return (.southeast, .southwest)
        case .southwest: return (.south, .west)
        case .west: return (.southwest, .northwest)
        case .northwest: return (.west, .north)
        }
    }
    
    func next(from c: Coordinate) -> Coordinate? {
        let xVec = c.x.rawValue + vector.0
        let yVec = c.y.rawValue + vector.1
        
        if let xPos = XPos(rawValue: xVec),
           let yPos = YPos(rawValue: yVec) {
            return Coordinate(x: xPos, y: yPos)
        } else {
            return nil
        }
    }
    
    func next(from pos: (XPos, YPos)) -> (XPos, YPos)? {
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

extension Set where Element == Coordinate {
    func contains(sequence: [Coordinate]) -> Bool {
        sequence.allSatisfy { self.contains($0) }
    }
    
    mutating func insert(col x: XPos) {
        let col = Coordinate.getColumn(x)
        self.formUnion(col)
    }
    
    mutating func insert(row y: YPos) {
        let row = Coordinate.getRow(y)
        self.formUnion(row)
    }
}

extension Array where Element == Tile {
    var hasEmpty: Bool {
        !allOccupied
    }
    
    var allOccupied: Bool {
        self.allSatisfy { $0 != .empty }
    }
}

extension Array where Element == Array<Tile> {
    
    func getColumn(_ x: XPos) -> [Tile] {
        YPos.allCases.map { self[x, $0] }
    }
    
    func getRow(_ y: YPos) -> [Tile] {
        XPos.allCases.map { self[$0, y] }
    }
    
    subscript(_ c: Coordinate) -> Tile {
        get { self[c.y.rawValue][c.x.rawValue] }
        set { self[c.y.rawValue][c.x.rawValue] = newValue }
    }
    
    subscript(x: XPos, y: YPos) -> Tile {
        get { self[y.rawValue][x.rawValue] }
        set { self[y.rawValue][x.rawValue] = newValue }
    }
    
    subscript(pos: (XPos, YPos)) -> Tile {
        get { self[pos.1.rawValue][pos.0.rawValue] }
        set { self[pos.1.rawValue][pos.0.rawValue] = newValue }
    }
    
    func getCount(ofType type: Tile) -> Int {
        var count = 0
        for row in self {
            for item in row {
                if item == type { count += 1 }
            }
        }
        return count
    }
}
