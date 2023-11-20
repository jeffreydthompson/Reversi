//
//  ReversiApp.swift
//  Reversi
//
//  Created by Jeffrey Thompson on 11/18/23.
//

import SwiftUI

@main
struct ReversiApp: App {
    var body: some Scene {
        WindowGroup {
            GameView(game: Game(human: .black))
        }
    }
}
