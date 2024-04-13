//
//  Board+TestExtensions.swift
//  ReversiTests
//
//  Created by Jeffrey Thompson on 11/19/23.
//

import Foundation
@testable import Reversi

extension Coin {
    var rawValue: String {
        switch self {
        case .black: "⚫️"
        case .white: "⚪️"
        }
    }
    
    init?(rawValue: String) {
        if rawValue == "⚫️" { self = .black }
        else if rawValue == "⚪️" { self = .white }
        else { return nil }
    }
}

extension ReversiPlayer {
    var rawValue: String {
        switch self {
        case .black: "⚫️"
        case .white: "⚪️"
        }
    }
    
    init?(rawValue: String) {
        if rawValue == "⚫️" { self = .black(.human) }
        else if rawValue == "⚪️" { self = .white(.human) }
        else { return nil }
    }
}

extension Square {
    var rawValue: String {
        switch self {
        case .empty: "🟩"
        case .occupied(let player): player.rawValue
        }
    }
    
    init?(rawValue: String) {
        if rawValue == "⚫️" || rawValue == "⚪️" {
            guard let coin = Coin(rawValue: rawValue) else { return nil }
            self = .occupied(coin)
        } else if rawValue == "🟩" {
            self = .empty
        } else {
            return nil
        }
    }
}

extension Tile {
    var rawValue: String {
        switch self {
        case .empty: "🟩"
        case .white: "⚪️"
        case .black: "⚫️"
        }
    }
    
    init?(rawValue: String) {
        if rawValue == "🟩" { self = .empty; return }
        if rawValue == "⚫️" { self = .black; return }
        if rawValue == "⚪️" { self = .white; return }
        return nil
    }
}

extension Player {
    var rawValue: String {
        switch self {
        case .black: "⚫️"
        case .white: "⚪️"
        }
    }
    
    init?(rawValue: String) {
        if rawValue == "⚫️" { self = .black; return }
        if rawValue == "⚪️" { self = .white; return }
        return nil
    }
}

extension ReversiBoard {
    
    init?(from string: String) {
        let arys = string.split(separator: "\n")
        guard arys.count == 8 else { return nil }
        guard arys.reduce(true, { partialResult, ary in
            partialResult && ary.count == 8
        }) else { return nil }
        
        let squares = arys.reversed().map { ary in
            ary.compactMap { char in
                Square(rawValue: "\(char)")
            }
        }
        self.init(squares: squares)
    }
    
    var debugString: String {
        var stringArys = [String]()
        
        squares.forEach { row in
            var rowStr = ""
            row.forEach { entry in
                rowStr += entry.rawValue
            }
            stringArys.append(rowStr)
        }
        
        stringArys.reverse()
        var outputString = ""
        stringArys.forEach {
            outputString += $0
            outputString += "\n"
        }
        return outputString.trimmingCharacters(in: .newlines)
    }
    
}

extension Board {
    
    convenience init?(from string: String) {
        let arys = string.split(separator: "\n")
        guard arys.count == 8 else { return nil }
        guard arys.reduce(true, { partialResult, ary in
            partialResult && ary.count == 8
        }) else { return nil }
        self.init()
        tiles = arys.reversed().map { ary in
            ary.compactMap { char in
                Tile(rawValue: "\(char)")
            }
        }
    }
    
    var debugString: String {
        var stringArys = [String]()
        
        tiles.forEach { row in
            var rowStr = ""
            row.forEach { entry in
                rowStr += entry.rawValue
            }
            stringArys.append(rowStr)
        }
        
        stringArys.reverse()
        var outputString = ""
        stringArys.forEach {
            outputString += $0
            outputString += "\n"
        }
        outputString.removeLast()
        return outputString
    }
}
