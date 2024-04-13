//
//  GameView.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 11/20/23.
//

import Foundation
import SwiftUI

struct GameView: View {
    
    @State var game: Game
    
    var body: some View {
        ZStack {
            Color.gray
            
            Group {
                switch game.state {
                case .normal:
                    board
                case .error(let error):
                    VStack {
                        Text(String(describing: error))
                        Button {
                            game.dismissError()
                        } label: {
                            Text("Dismiss")
                        }

                    }
                case .end(let winner):
                    VStack {
                        Text("\(winner.description) is the winner")
                        Button("Play again") {
                            game.reset()
                        }
                    }
                }
            }
        }
    }
    
    var board: some View {
        VStack {
            HStack {
                Text("Turn: \(game.turn.description)")
            }
            VStack(spacing: .zero) {
                ForEach(XPos.allCases) { x in
                    HStack(spacing: .zero) {
                        ForEach(YPos.allCases) { y in
                            button((x, y))
                        }
                    }
                }
            }
        }
    }
    
    func button(_ pos: (XPos, YPos)) -> some View {
        Button(action: {
            if game.turn == game.human {
                game.executeMove(at: pos)
            }
        }, label: {
            tileImageView(game.board[pos.0,pos.1])
        })
    }
    
    func tileImageView(_ tile: Tile) -> some View {
        Group {
            switch tile {
            case .empty: return Image(systemName: "square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.green)
            case .black: return Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.black)
            case .white: return Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    GameView(game: Game(human: .black))
}

struct ReversiGameView: View {
    
    @State var vm: ReversiGameViewModel
    
    var body: some View {
        switch vm.state {
        case .unitialized: Button("Start") {
            vm.initializeGame(white: .human, black: .human)
        }
        case .inPlay(set: let set, board: let board): VStack {
            Text("Turn: \(set.turn)")
            BoardView(board: board) { x, y in
                try? vm.move(to: .init(x: x, y: y), for: set, on: board)
            }
        }
        case .tie(board: let board):
            VStack {
                Text("It's a tie")
                BoardView(board: board)
            }
            .overlay {
                Button("play again") {
                    vm.initializeGame(white: .human, black: .human)
                }
            }
        case .win(player: let player, board: let board):
            VStack {
                Text("Turn: \(player) wins")
                BoardView(board: board)
            }
            .overlay {
                Button("play again") {
                    vm.initializeGame(white: .human, black: .human)
                }
            }
        }
    }
}

struct BoardView: View {
    
    var board: ReversiBoard
    var didPress: ((XPos, YPos) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: .zero) {
            ForEach(YPos.allCases.reversed()) { y in
                HStack(spacing: .zero) {
                    ForEach(XPos.allCases) { x in
                        button((x, y))
                    }
                }
            }
        }
    }
    
    func button(_ pos: (XPos, YPos)) -> some View {
        Button(action: {
            didPress?(pos.0, pos.1)
        }, label: {
            tileImageView(board[.init(x: pos.0, y: pos.1)])
        })
    }
    
    func tileImageView(_ tile: Square) -> some View {
        Group {
            switch tile {
            case .empty: 
                return Image(systemName: "square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.green)
            case .occupied(let coin):
                return Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(coin.color)
            }
        }
    }
}

extension Coin {
    var color: Color {
        switch self {
        case .black:
            return .black
        case .white:
            return .white
        }
    }
}
