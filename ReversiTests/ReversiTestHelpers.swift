//
//  ReversiTestHelpers.swift
//  ReversiTests
//
//  Created by Jeffrey Thompson on 11/18/23.
//

import Foundation

/*
 8🟩🟩🟩🟩🟩🟩🟩🟩
 7🟩🟩🟩🟩🟩🟩🟩🟩
 6🟩🟩🟩🟩🟩🟩🟩🟩
 5🟩🟩🟩⚫️⚪️🟩🟩🟩
 4🟩🟩🟩⚪️⚫️🟩🟩🟩
 3🟩🟩🟩🟩🟩🟩🟩🟩
 2🟩🟩🟩🟩🟩🟩🟩🟩
 1🟩🟩🟩🟩🟩🟩🟩🟩
  A BC D EF G H
 */

let testStrStandardSetup: String = """
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩⚫️⚪️🟩🟩🟩
🟩🟩🟩⚪️⚫️🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
"""

let testStrSetup: String = """
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩⚪️⚪️🟩🟩🟩🟩🟩
"""

let testFirstMove: String = """
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩⚫️⚫️⚫️🟩🟩
🟩🟩🟩⚪️⚫️🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
"""

let testAccumulationString: String = """
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
🟩🟩⚫️🟩🟩🟩🟩🟩
🟩🟩⚪️⚫️⚫️⚫️🟩🟩
🟩🟩🟩⚪️⚫️🟩🟩🟩
🟩🟩🟩⚪️⚫️🟩🟩🟩
🟩🟩🟩🟩⚫️🟩🟩🟩
🟩🟩🟩🟩🟩🟩🟩🟩
"""

let something: String = """
⚫️⚫️⚫️⚫️⚪️⚫️⚫️⚫️
⚫️⚫️⚫️⚪️⚪️⚫️⚫️⚫️
⚫️⚪️⚪️⚫️⚪️⚪️⚫️⚫️
⚫️⚪️⚪️⚪️⚫️⚪️⚫️⚫️
⚫️⚪️⚪️⚫️⚪️⚫️⚫️⚫️
⚫️⚪️⚪️⚪️⚪️⚪️⚫️⚫️
⚫️🟩⚪️⚫️⚫️⚫️⚫️⚫️
⚫️⚫️⚫️⚫️⚫️⚫️⚫️⚪️
"""
