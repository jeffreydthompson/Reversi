//
//  Board+TestExtensions.swift
//  ReversiTests
//
//  Created by Jeffrey Thompson on 11/19/23.
//

import Foundation
@testable import Reversi

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
