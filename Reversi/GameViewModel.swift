//
//  GaveViewModel.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 4/17/24.
//

import Foundation

@Observable
class GameViewModel {
    
    var game: Game = .uninitiated {
        didSet {
            computerMove()
        }
    }
    
    var boardMessage: String {
        switch game {
        case .inPlay(let players, _):
            return "It's \(players.turn.description)'s turn"
        case .tie:
            return "It's a tie!"
        case .win(_, let player):
            return "\(player.description) wins"
        default: return ""
        }
    }
    
    func initiateGame(_ ps: PlayerSet) {
        game = .inPlay(players: ps, board: Board.defaultBoard())
    }
    
    func reset() {
        game = .uninitiated
    }
    
    func humanMove(_ c: Coordinate) {
        guard case .inPlay(players: let ps, board: let b) = game,
              ps.turn.type == .human else { return }
        game = makeHumanMove(to: c, players: ps, board: b)
    }
    
    func computerMove() {
        guard case .inPlay(players: let ps, board: let b) = game,
              ps.turn.type == .computer else { return }
        do {
            game = try makeComputerMove(players: ps, board: b)
        } catch {
            game = .error(error)
        }
    }
}

extension Player {
    var description: String {
        switch self {
        case .white:
            return "White"
        case .black:
            return "Black"
        }
    }
}
