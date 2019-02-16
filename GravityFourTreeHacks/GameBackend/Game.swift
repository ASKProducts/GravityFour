//
//  Game.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/15/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation
import UIKit

struct Player : Equatable{
    let ID: Int
    let name: String
}

struct Piece {
    let player: Player
    let turnPlayed: Int
}

enum Move {
    enum Direction: String{
        case left = "L", right = "R"
    }
    case drop(Int)
    case rotate(Direction)
    
    func toString() -> String {
        switch self {
        case let .drop(col):
            return "\(col)"
        case let .rotate(dir):
            return dir.rawValue
        }
    }
}

struct WinResult{
    let player: Player
    let startPosition: Coord
    let direction: Coord
}

struct Coord {
    let c: Int
    let r: Int
}

class Game {
    //NOTE: games start at turn 1
    var turnNumber: Int
    var turnHistory: [Move]
    
    var playerOne: Player
    var playerTwo: Player
    func player(_ num: Int) -> Player{
        guard num == 1 || num == 2 else {
            fatalError("player() called with input neither 1 nor 2")
        }
        return num == 1 ? playerOne : playerTwo
    }
    var currentPlayer: Player {
        return player((turnNumber + 1 ) % 2 + 1)
    }
    
    //NOTE: col and row are indexed starting at 0
    //NOTE: board[i] is the ith column of the board, so to get the piece at row r and col c, do board[c][r]
    var board: [[Piece?]]
    var numRows: Int
    var numCols: Int
    
    var winResults: [WinResult]
    
    let winLength = 4
    
    init(initialRows: Int, initialCols: Int, playerOne: Player, playerTwo: Player) {
        turnNumber = 1
        turnHistory = []
        
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        
        numRows = initialRows
        numCols = initialCols
        
        board = Array(repeating: Array(repeating: nil, count: numRows), count: numCols)
        
        winResults = []
    }
    
    //returns the number of pieces in column col
    func colHeight(_ col: Int) -> Int{
        return board[col].filter{$0 != nil}.count
    }
    
    func canMakeMove(move: Move) -> Bool {
        switch move {
        case let .drop(col):
            if col >= numCols { return false }
            return colHeight(col) < numRows
        case .rotate:
            return true
        }
    }
    
    //just makes appropriate modifications to the board, turnNumber, etc. Does not check for winners
    //returns whether or not the move was successfully made
    func makeMove(player: Player, move: Move) -> Bool{
        guard canMakeMove(move: move) else { return false }
        switch move {
        case let .drop(col):
            let height = colHeight(col)
            board[col][height] = Piece(player: player, turnPlayed: turnNumber)
        case let .rotate(dir):
            rotateBoard(dir)
        }
        
        turnHistory.append(move)
        turnNumber += 1
        
        return true
    }
    
    func makeMove(move: Move) -> Bool{
        return makeMove(player: currentPlayer, move: move)
    }
    
    func getRow(_ r: Int) -> [Piece?] {
        return (0..<numCols).map{board[$0][r]}
    }
    
    func compress(column: [Piece?]) -> [Piece?] {
        let len = column.count
        var compressed = column.filter{$0 != nil}
        let compressedLen = compressed.count
        compressed.append(contentsOf: [Piece?](repeating: nil, count: len-compressedLen))
        return compressed
    }
    
    func rotateBoard(_ dir: Move.Direction){
        switch dir {
        case .right:
            var newBoard: [[Piece?]] = Array(repeating: [], count: numRows)
            for r in 0..<numRows {
                newBoard[r] = compress(column: getRow(r).reversed())
            }
            (numRows, numCols) = (numCols, numRows)
            board = newBoard
            
        case .left:
            var newBoard: [[Piece?]] = Array(repeating: [], count: numRows)
            for r in 0..<numRows {
                newBoard[r] = compress(column: getRow(numRows - 1 - r))
            }
            (numRows, numCols) = (numCols, numRows)
            board = newBoard
        }
    }
    
    //returns the chain of pieces starting at start and in the direction of dir with length len. Empty spots and spots off the board are all nil
    func getChain(start: Coord, direction: Coord, length: Int) -> [Piece?]{
        var chain: [Piece?] = []
        for i in 0..<length{
            let newCoord = Coord(c: start.c + direction.c * i,
                                 r: start.r + direction.r * i)
            if !((0..<numCols).contains(newCoord.c)) || !((0..<numRows).contains(newCoord.r)) {
                break
            }
            chain.append(board[newCoord.c][newCoord.r])
        }
        
        chain.append(contentsOf: [Piece?](repeating: nil, count: length-chain.count))
        
        return chain
    }
    //returns whether a winner was detected at all, and updates self.winResults
    func checkWinner() -> Bool {
        let winDirections = [ Coord(c: 1, r: 0),
                              Coord(c: 0, r: 1),
                              Coord(c: 1, r: 1),
                              Coord(c: 1, r: -1)]
        
        winResults = []
        
        for c in 0..<numCols {
            for r in 0..<numRows {
                for dir in winDirections{
                    let chain = getChain(start: Coord(c: c, r: r), direction: dir, length: winLength)
                    if (chain.filter{$0 != nil}.count) < winLength { continue }
                    if (chain.filter{$0!.player == chain[0]!.player}).count == winLength {
                        winResults.append(WinResult(player: chain[0]!.player,
                                                    startPosition: Coord(c: c, r: r),
                                                    direction: dir))
                    }
                }
            }
        }
        
        return winResults.count > 0
    }
    
    
    func toString() -> String {
        var str = ""
        for r in 0..<numRows {
            let row = numRows - 1 - r
            str += " "
            for piece in getRow(row){
                if let piece = piece {
                    str += piece.player == playerOne ? "X" : "O"
                }
                else{
                    str += "."
                }
                str += " "
            }
            str += "\n"
        }
        return str
    }
}
