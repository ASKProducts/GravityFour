//
//  GameScene.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import UIKit
import SpriteKit

enum GameType{
    case LocalMultiplayer, LocalSinglePlayer, OnlineTurnBased, OnlineLive
}

class GameScene: SKScene {
    
    var playerOneName = "P"
    var playerTwoName = "Q"
    
    var game: Game!
    
    var gameType: GameType!
    
    let BOARD_WIDTH_RATIO = CGFloat(0.85)
    var board: BoardNode!
    
    let BOARD_BUTTON_OFFSET = CGFloat(30)
    
    var rotateLeftButton: RotateButtonNode!
    var rotateRightButton: RotateButtonNode!
    
    var goBackButton: GoBackButton!
    var restartButton: RestartButton!
    var titleLabel: SKLabelNode!
    var playerOneLabel: SKLabelNode!
    var playerTwoLabel: SKLabelNode!
    
    let TITLE_LABEL_HEIGHT = CGFloat(50)
    
    let NAME_TO_BOARD_RATIO = CGFloat(3.0/7.0)
    
    var gvc: GameViewController!
    
    var turnIndicator: PieceNode!
    
    override func didMove(to view: SKView) {
        if gameType == .LocalMultiplayer{
            game = Game(initialRows: 6, initialCols: 7,
                        playerOne: Player(ID: 1, name: playerOneName),
                        playerTwo: Player(ID: 2, name: playerTwoName))
            
            board = BoardNode(game: game, width: BOARD_WIDTH_RATIO * UIScreen.main.bounds.width, gameScene: self)
            self.addChild(board)
            
          
          /*
            self.run(SKAction.sequence([SKAction.wait(forDuration: 5),
                                        SKAction.run{ self.board.rotateLeft() },
                                        SKAction.wait(forDuration: 3),
                                        SKAction.run{ /*self.board.rotateRight()*/ }]))*/
            
            rotateLeftButton = RotateButtonNode(dir: .left, board: board, gameScene: self)
            rotateLeftButton.position = CGPoint(x: -board.width/2 + board.width/4,
                                                y: -board.height/2 - rotateLeftButton.size.height/2 - BOARD_BUTTON_OFFSET)
            self.addChild(rotateLeftButton)
            
            rotateRightButton = RotateButtonNode(dir: .right, board: board, gameScene: self)
            rotateRightButton.position = CGPoint(x: board.width/2 - board.width/4,
                                                y: -board.height/2 - rotateRightButton.size.height/2 - BOARD_BUTTON_OFFSET)
            self.addChild(rotateRightButton)
            
            titleLabel = SKLabelNode()
            titleLabel.fontName = "Helvetica"
            titleLabel.text = "Gravity Four"
            adjustLabelFontSizeToFitRect(labelNode: titleLabel, rect: CGRect(x: -size.width/2,
                                                                             y: size.height/2 - 2*TITLE_LABEL_HEIGHT,
                                                                             width: size.width,
                                                                             height: TITLE_LABEL_HEIGHT))
            self.addChild(titleLabel)
            
            goBackButton = GoBackButton(gameScene: self)
            goBackButton.position = CGPoint(x: -size.width/2 + TITLE_LABEL_HEIGHT/2 + 15, y: size.height/2 - TITLE_LABEL_HEIGHT)
            goBackButton.isUserInteractionEnabled = true
            
            restartButton = RestartButton(gameScene: self)
            restartButton.position = CGPoint(x: size.width/2 - TITLE_LABEL_HEIGHT/2 - 15, y: size.height/2 - TITLE_LABEL_HEIGHT)
            restartButton.isUserInteractionEnabled = true
            
            self.addChild(restartButton)
            self.addChild(goBackButton)
            
            playerOneLabel = SKLabelNode()
            playerOneLabel.fontName = "Helvetica"
            playerOneLabel.fontColor = .black
            playerOneLabel.text = game.playerOne.name
            let p1labelRect = CGRect(x: -board.width/2,
                                     y: board.width/2 + board.cellWidth,
                                     width: NAME_TO_BOARD_RATIO * board.width, height: TITLE_LABEL_HEIGHT)
            adjustLabelFontSizeToFitRect(labelNode: playerOneLabel, rect: p1labelRect)
            self.addChild(playerOneLabel)
            
            playerTwoLabel = SKLabelNode()
            playerTwoLabel.fontName = "Helvetica"
            playerTwoLabel.fontColor = .black
            playerTwoLabel.text = game.playerTwo.name
            let p2labelRect = CGRect(x: -board.width/2 + (1.0 - NAME_TO_BOARD_RATIO)*board.width,
                                     y: board.width/2 + board.cellWidth,
                                     width: NAME_TO_BOARD_RATIO * board.width, height: TITLE_LABEL_HEIGHT)
            adjustLabelFontSizeToFitRect(labelNode: playerTwoLabel, rect: p2labelRect)
            self.addChild(playerTwoLabel)
            
            turnIndicator = PieceNode(player: game.playerOne, game: game, board: board, flipped: false)
            turnIndicator.xScale = 0.5
            turnIndicator.yScale = 0.5
            
            turnIndicator.position = CGPoint(x: playerOneLabel.position.x, y: playerOneLabel.position.y + TITLE_LABEL_HEIGHT)
            turnIndicator.physicsBody?.isDynamic = false
            self.addChild(turnIndicator)
            
        }
        
    }
    
    func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect) {
        
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / labelNode.frame.width, rect.height / labelNode.frame.height)
        
        // Change the fontSize.
        labelNode.fontSize *= scalingFactor
        
        // Optionally move the SKLabelNode to the center of the rectangle.
        labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
    }
    
    func suspendInteraction(for duration: TimeInterval){
        self.children.forEach{$0.isUserInteractionEnabled = false}
        self.goBackButton.isUserInteractionEnabled = true
        self.restartButton.isUserInteractionEnabled = true
        
        self.run(SKAction.wait(forDuration: duration)){
            self.children.forEach{$0.isUserInteractionEnabled = true}
        }
    }
    
    func deactivateInteraction(){
        self.children.forEach{$0.isUserInteractionEnabled = false}
        self.goBackButton.isUserInteractionEnabled = true
        self.restartButton.isUserInteractionEnabled = true
        
    }
    
    func executeDrop(in col: Int){
        suspendInteraction(for: 1)
        
        let newPiece = PieceNode(player: game.currentPlayer, game: game, board: board, flipped: board.sideWays)
        let absoluteCoords = CGPoint(x: -board.width/2 + board.cellWidth/2 + board.cellWidth * CGFloat(col),
                                     y: board.height/2 + board.cellWidth/2)
        newPiece.position = board.relativeCoords(from: absoluteCoords)
        
        board.pieces.append(newPiece)
        board.addChild(newPiece)
        
        _ = game.makeMove(move: .drop(col))
        
        checkWin(after: 1)
        
        toggleIndicator()
    
    }
    
    func executeRotation(dir: Move.Direction){
        suspendInteraction(for: 1.5)
        switch dir {
        case .left:
            board.rotateLeft()
        case .right:
            board.rotateRight()
        }
        _ = game.makeMove(move: .rotate(dir))
        
        checkWin(after: 1.5)
        
        toggleIndicator()
    }
    
    func toggleIndicator(){
        let newPos = CGPoint(x: -turnIndicator.position.x, y: turnIndicator.position.y)
        turnIndicator.run(SKAction.move(to: CGPoint(x: 0, y: turnIndicator.position.y), duration: 0.5))
        turnIndicator.run(SKAction.fadeOut(withDuration: 0.5)){
            self.turnIndicator.removeFromParent()
            
            self.turnIndicator = PieceNode(player: self.game.currentPlayer, game: self.game, board: self.board, flipped: false)
            self.turnIndicator.physicsBody?.isDynamic = false
            self.turnIndicator.position = CGPoint(x: 0, y: newPos.y)
            self.turnIndicator.alpha = 0
            self.turnIndicator.xScale = 0.5
            self.turnIndicator.yScale = 0.5
            
            self.addChild(self.turnIndicator)
            self.turnIndicator.run(SKAction.move(to: newPos, duration: 0.5))
            self.turnIndicator.run(SKAction.fadeIn(withDuration: 0.5))
        }
        
    }
    
    func checkWin(after: TimeInterval){
        self.run(SKAction.wait(forDuration: after)){
            self.checkWin()
        }
    }
    
    func checkWin(){
        
        if game.checkWinner() {
            
            deactivateInteraction()
            
            let results = game.winResults
            let p1wins = results.filter{$0.player == game.playerOne}
            let p2wins = results.filter{$0.player == game.playerTwo}
            
            if p1wins.count > 0 && p2wins.count > 0 {
                drawWinResult(p1wins[0])
                drawWinResult(p2wins[0])
                showWinLabel("It's a Tie!")
            }
            else{
                let winResult = results[0]
                drawWinResult(winResult)
                showWinLabel("\(winResult.player.name) wins!")
            }
        }
        else if game.isBoardFull() {
            showWinLabel("It's a Tie!")
            deactivateInteraction()
        }
    }
    
    func showWinLabel(_ text: String){
        let winLabel = SKLabelNode()
        winLabel.fontSize = 50
        winLabel.horizontalAlignmentMode = .center
        winLabel.fontColor = .black
        winLabel.fontName = "Helvetica"
        winLabel.verticalAlignmentMode = .center
        winLabel.text = text
        winLabel.position = CGPoint(x: 0, y: -board.height/2 - BOARD_BUTTON_OFFSET - rotateLeftButton.size.height - winLabel.frame.size.height)
        winLabel.alpha = 0
        winLabel.run(SKAction.fadeIn(withDuration: 2))
        self.addChild(winLabel)
    }
    
    
    func drawWinResult(_ winResult: WinResult){
        let startx = -board.width/2 + board.cellWidth*(CGFloat(winResult.startPosition.c) + 0.5)
        let starty = -board.height/2 + board.cellWidth*(CGFloat(winResult.startPosition.r) + 0.5)
        let startPoint = CGPoint(x: startx,
                                 y: starty)
        
        let endPosition = Coord(c: winResult.startPosition.c + 3 * winResult.direction.c,
                                r: winResult.startPosition.r + 3 * winResult.direction.r)
        
        
        let endPoint = CGPoint(x: -board.width/2 + board.cellWidth*(CGFloat(endPosition.c) + 0.5),
                               y: -board.height/2 + board.cellWidth*(CGFloat(endPosition.r) + 0.5))
        
        let winPath = CGMutablePath()
        winPath.addLines(between: [startPoint, endPoint])
        let winNode = SKShapeNode(path: winPath)
        winNode.strokeColor = .blue
        winNode.lineWidth = 10
        winNode.alpha = 0
        winNode.lineCap = .round

        self.addChild(winNode)
        winNode.zPosition = 10
        winNode.run(SKAction.fadeIn(withDuration: 2))
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}

