//
//  GameView.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 11/20/23.
//

import Foundation
import SwiftUI

struct GameView: View {
    
    @State var vm = GameViewModel()
    
    @ViewBuilder
    var body: some View {
        ZStack {
            Color.gray
            
            Group {
                switch vm.game {
                case .uninitiated:
                    UninitiatedView(callback: vm.initiateGame(_:))
                case .inPlay(let players, let board):
                    BoardView(message: vm.boardMessage, board: board, callBack: vm.humanMove(_:))
                case .tie(let board), .win(let board, _):
                    BoardView(message: vm.boardMessage, board: board, resetMessage: "Play again.") {
                        vm.reset()
                    }
                case .error(let error):
                    VStack {
                        Text("Error: \(error.localizedDescription)")
                        Button("Dismiss") {
                            vm.reset()
                        }
                    }
                }
            }
        }
    }
}

struct BoardView: View {
    
    let message: String
    let board: Board
    let callBack: ((Coordinate) -> Void)?
    let resetMessage: String?
    let resetCallback: (() -> Void)?
    
    init(message: String,
         board: Board,
         callBack: ( (Coordinate) -> Void)? = nil,
         resetMessage: String? = nil,
         resetCallback: ( () -> Void)? = nil) {
        self.message = message
        self.board = board
        self.callBack = callBack
        self.resetMessage = resetMessage
        self.resetCallback = resetCallback
    }
    
    var body: some View {
        VStack {
            Text(message)
            
            VStack(spacing: .zero) {
                ForEach(XPos.allCases) { x in
                    HStack(spacing: .zero) {
                        ForEach(YPos.allCases) { y in
                            button(.init(x: x, y: y))
                        }
                    }
                }
            }
            
            Button(resetMessage ?? "") {
                resetCallback?()
            }
        }
    }
    
    func button(_ c: Coordinate) -> some View {
        Button(action: {
            callBack?(c)
        }, label: {
            tileImageView(board[c])
        })
    }
    
    func tileImageView(_ tile: Tile) -> some View {
        Group {
            switch tile {
            case .empty: return Image(systemName: "square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.green)
            case .occupied(let player): return Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(player == .white ? .white : .black)
            }
        }
    }
}

struct UninitiatedView: View {
    
    var callback: (PlayerSet) -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Button("⚫️: Human | ⚪️: Human") {
                callback(.init(white: .human, black: .human))
            }
            Button("⚫️: Human | ⚪️: Computer") {
                callback(.init(white: .computer, black: .human))
            }
            Button("⚫️: Computer | ⚪️: Human") {
                callback(.init(white: .human, black: .computer))
            }
        }
    }
}

#Preview {
    GameView()
}

