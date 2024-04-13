//
//  Board.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 11/18/23.
//

import Foundation

enum Coin: Equatable {
    case black, white
}

enum PlayerType: Equatable {
    case human, computer
}

enum ReversiPlayer: Equatable {
    case white(PlayerType)
    case black(PlayerType)
    
    var coin: Coin {
        switch self {
        case .white: .white
        case .black: .black
        }
    }
    
    private var isWhite: Bool {
        switch self {
        case .white: return true
        case .black: return false
        }
    }
    
    static func == (rhs: ReversiPlayer, lhs: ReversiPlayer) -> Bool {
        rhs.isWhite == lhs.isWhite
    }
}

enum PlayersSet {
    case whiteTurn(black: ReversiPlayer, white: ReversiPlayer)
    case blackTurn(black: ReversiPlayer, white: ReversiPlayer)
    
    var white: ReversiPlayer {
        switch self {
        case .whiteTurn(_, let white), .blackTurn(_, let white): return white
        }
    }
    
    var black: ReversiPlayer {
        switch self {
        case .whiteTurn(let black, _), .blackTurn(let black, _): return black
        }
    }
    
    var turn: ReversiPlayer {
        switch self {
        case .whiteTurn(_, let white): return white
        case .blackTurn(let black, _): return black
        }
    }
    
    var turnOpponent: ReversiPlayer {
        switch self {
        case .whiteTurn(let black, _): return black
        case .blackTurn(_, let white): return white
        }
    }
    
    func switchTurn() -> PlayersSet {
        switch self {
        case .whiteTurn(let black, let white):
            return .blackTurn(black: black, white: white)
        case .blackTurn(let black, let white):
            return .whiteTurn(black: black, white: white)
        }
    }
}

enum Square: Equatable {
    case occupied(Coin)
    case empty
    
    var isEmpty: Bool {
        switch self {
        case .occupied:
            return false
        case .empty:
            return true
        }
    }
    
    func isOccupied(by coin: Coin) -> Bool {
        switch self {
        case .empty: return false
        case .occupied(let thisCoin):
            return thisCoin == coin
        }
    }
    
    static func ==(lhs: Square, rhs: Square) -> Bool {
        switch lhs {
        case .occupied(let coin):
            return rhs.isOccupied(by: coin)
        case .empty:
            return rhs.isEmpty
        }
    }
}

extension Array where Element == Array<Square> {
    subscript(_ c: Coordinate) -> Square {
        get { self[c.y.rawValue][c.x.rawValue] }
        set { self[c.y.rawValue][c.x.rawValue] = newValue }
    }
}

struct Coordinate: Hashable {
    let x: XPos
    let y: YPos
}

struct ReversiBoard {
    
    enum BoardError: Error {
        case alreadyOccupied
        case illegalMove
    }
    
    let squares: [[Square]]
    let stableSquares: Set<Coordinate> // cache saves calculation
    
    init(squares: [[Square]], stableSquares: Set<Coordinate>) {
        self.squares = squares
        self.stableSquares = Set<Coordinate>()
    }
    
    init() {
        var sqs: [[Square]] = Array(repeating: Array(repeating: .empty, count: XPos.allCases.count), count: YPos.allCases.count)
        sqs[XPos.d.rawValue][YPos._4.rawValue] = .occupied(.white)
        sqs[XPos.e.rawValue][YPos._5.rawValue] = .occupied(.white)
        sqs[XPos.d.rawValue][YPos._5.rawValue] = .occupied(.black)
        sqs[XPos.e.rawValue][YPos._4.rawValue] = .occupied(.black)
        self.squares = sqs
        self.stableSquares = Set<Coordinate>()
    }
    
    func set(
        _ coin: Coin,
        at coordinate: Coordinate) throws -> ReversiBoard {
            
            if self[coordinate] != .empty { throw BoardError.alreadyOccupied }
            let tileFlips = getTileFlips(for: coin, from: coordinate)
            guard !tileFlips.isEmpty else { throw BoardError.illegalMove }
            var copySquares = self.squares
            for c in tileFlips { copySquares[c] = .occupied(coin) }
            copySquares[coordinate] = .occupied(coin)
            return ReversiBoard(squares: copySquares, stableSquares: stableSquares)
        }
    
    var emptySquares: [Coordinate] {
        var positions = [Coordinate]()
        for x in XPos.allCases {
            for y in YPos.allCases {
                let coordinate = Coordinate.init(x: x, y: y)
                if self[coordinate].isEmpty { positions.append(coordinate) }
            }
        }
        return positions
    }
    
    func getPositionsFor(square: Square) -> [Coordinate] {
        var positions = [Coordinate]()
        for x in XPos.allCases {
            for y in YPos.allCases {
                let coordinate = Coordinate.init(x: x, y: y)
                if self[coordinate] == square { positions.append(coordinate) }
            }
        }
        return positions
    }
    
    static func calculateStables(
        for player: ReversiPlayer,
        on board: ReversiBoard) -> ReversiBoard {

            // corner and normalVector
            let corners: [Coordinate: Direction] = [
                .init(x: .a, y: ._1): .northeast,
                .init(x: .a, y: ._8): .southeast,
                .init(x: .h, y: ._1): .northwest,
                .init(x: .h, y: ._8): .northeast
            ]
            
            var stables = Set<Coordinate>()
            
            for (corner, vector) in corners {
                var insetSearching = true
                var c = corner
                while insetSearching {
                    let localS = cornerSearch(forPlayer: player, from: c, d: vector)
                    stables.formUnion(localS)
                    guard !localS.isEmpty,
                          let nc = vector.next(from: c) else {
                        insetSearching = false
                        continue
                    }
                    
                    c = nc
                }
            }
            
            return .init(squares: squares, stableSquares: stables)
        }
    
    static func cornerSearch(
        forPlayer p: ReversiPlayer,
        from c: Coordinate,
        direction d: Direction,
        on b: ReversiBoard) -> ReversiBoard {
            
            var s = Set<Coordinate>()
            guard isStable(for: p, withVector: d, at: c) else { return s }
            
            s.insert(c)
            [d.leftLeg, d.rightLeg].forEach { ld in
                var ldStable = true
                var lc = c
                while ldStable {
                    guard let nc = ld.next(from: lc),
                          isStable(for: p, withVector: d, at: nc) else {
                        ldStable = false
                        continue
                    }
                    s.insert(nc)
                    lc = nc
                }
            }
            return s
        }
    
    static func isStable(
        for player: ReversiPlayer,
        withVector vector: Direction,
        at coordinate: Coordinate,
        on board: ReversiBoard) -> Bool {
            
            guard self[coordinate].isOccupied(by: player.coin) else { return false }
            if stableSquares.contains(coordinate) { return true }
            
            let o = vector.opposite.next(from: coordinate)
            let ol = vector.opposite.leftLeg.next(from: coordinate)
            let or = vector.opposite.rightLeg.next(from: coordinate)
            
            return [o, ol, or].reduce(into: true) { partialResult, cOptional in
                var localBool = false
                if let c = cOptional {
                    if self[c].isOccupied(by: player.coin) {
                        if self.stableSquares.contains(c) {
                            localBool = true
                        } else {
                            localBool = isStable(for: player, withVector: vector, at: coordinate)
                        }
                    }
                }
                partialResult = partialResult && localBool
            }
        }
    
    func checkCanMove(for coin: Coin) -> Bool {
        // if player wiped off the board, then cannot move.
        guard !getPositionsFor(square: .occupied(coin)).isEmpty else {
            return false
        }
        
        let emptyPositions = getPositionsFor(square: .empty)
        for position in emptyPositions {
            if checkIsMoveLegal(for: coin, at: position) {
                return true
            }
        }
        return false
    }
    
    func checkIsMoveLegal(
        for coin: Coin,
        at coordinate: Coordinate) -> Bool {
            guard self[coordinate].isEmpty else { return false }
            return !getTileFlips(for: coin, from: coordinate).isEmpty
        }
    
    // place coin at position and calculate opponent flips
    func getTileFlips(
        for coin: Coin,
        from coordinate: Coordinate) -> [Coordinate] {
            Direction.allCases.flatMap { direction in
                accumulateFlips(for: coin, heading: direction, from: coordinate) ?? []
            }
        }
    
    // accumulate flips in a single direction
    private func accumulateFlips(
        for coin: Coin,
        heading direction: Direction,
        from coordinate: Coordinate) -> [Coordinate]? {
            
            // out of bounds and empty are invalid search end conditions.
            guard let nextPos = direction.next(from: coordinate) else {
                return nil
            }
            if self[nextPos].isEmpty { return nil }
            
            // recursively searched and reached end condition
            // return an empty container that will be filled on the way back
            if self[nextPos].isOccupied(by: coin) { return [] }
            
            // remaining condition means this square is opponent.
            // keep moving on to the next square and if a valid container
            // is returned, fill it up and pass it back up.
            guard var result = accumulateFlips(for: coin, heading: direction, from: nextPos) else { return nil }
            result.append(nextPos)
            return result
        }
    
    subscript(c: Coordinate) -> Square {
        get { squares[c.y.rawValue][c.x.rawValue] }
    }
}

enum Player {
    case white, black
    
    var toggle: Player {
        switch self {
        case .white: return .black
        case .black: return .white
        }
    }
    
    var associatedTile: Tile {
        switch self {
        case .white: return .white
        case .black: return .black
        }
    }
    
    var description: String {
        switch self {
        case .white: "White"
        case .black: "Black"
        }
    }
}

enum Tile: Equatable {
    case empty, white, black
    var isEmpty: Bool { self == .empty }
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
        tiles = (0..<8).map { (_) -> [Tile] in 
            Array<Tile>(repeating: .empty, count: 8) }
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
    
    func isLegalMove(for player: Player, at pos: (XPos, YPos)) -> Bool {
        !getTileFlips(for: player, at: pos).isEmpty
    }
    
    func computerMoveSearch(for player: Player) -> [Int: [(XPos, YPos)]] {
        var score = [Int: [(XPos, YPos)]]()
        for x in XPos.allCases {
            for y in YPos.allCases {
                guard self[x,y].isEmpty else { continue }
                let result = getTileFlips(for: player, at: (x, y))
                if !result.isEmpty {
                    score[result.count, default: []].append((x, y))
                }
            }
        }
        return score
    }
    
    private func getTileFlips(for player: Player, at pos: (XPos, YPos)) -> [(XPos, YPos)] {
        Direction.allCases.flatMap { direction in
            accumulate(for: player, heading: direction, from: pos) ?? []
        }
    }
    
    private func accumulate(
        for player: Player,
        heading direction: Direction,
        from pos: (XPos, YPos)) -> [(XPos, YPos)]? {
        
            guard let nextPos = direction.next(from: pos) else { return nil }
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
    
    var rightLeg: Direction {
        switch self {
        case .north: return .northeast
        case .northeast: return .east
        case .east: return .southeast
        case .southeast: return .south
        case .south: return .southwest
        case .southwest: return .west
        case .west: return .northwest
        case .northwest: return .north
        }
    }
    
    var leftLeg: Direction {
        switch self {
        case .north: return .northwest
        case .northeast: return .north
        case .east: return .northeast
        case .southeast: return .east
        case .south: return .southeast
        case .southwest: return .south
        case .west: return .southwest
        case .northwest: return .west
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
    
    func next(from c: Coordinate) -> Coordinate? {
        let xVec = c.x.rawValue + vector.0
        let yVec = c.y.rawValue + vector.1
        
        if let xPos = XPos(rawValue: xVec),
           let yPos = YPos(rawValue: yVec) {
            return .init(x: xPos, y: yPos)
        } else {
            return nil
        }
    }
}

extension Array where Element == Direction {
    
    var corners: [Direction: [Direction]] {[
        .northwest: [.north, .west],
        .northeast: [.north, .east],
        .southeast: [.east, .south],
        .southwest: [.west, .south]
    ]}
    
    /*
     where a 3 point corner is established.
     */
    var twoSideStability: Bool {
        for (corner, legs) in corners {
            if self.contains(corner) {
                if self.contains(legs) {
                    return true
                }
            }
        }
        return false
    }
}
