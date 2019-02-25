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

enum AIDifficulty: Int{
    case easy = 0, medium = 1, hard = 2, extreme = 3
}

class GameScene: SKScene {
    
    var playerOneName = "P"
    var playerTwoName = "Q"
    
    var game: Game!
    
    var gameType: GameType!
    
    let BOARD_WIDTH_RATIO = CGFloat(0.85)
    var board: BoardNode!
    
    let BOARD_BUTTON_OFFSET = CGFloat(50)
    
    var rotateLeftButton: RotateButtonNode!
    var rotateRightButton: RotateButtonNode!
    
    var goBackButton: GoBackButton!
    var restartButton: RestartButton!
    var titleLabel: SKSpriteNode!
    var playerOneLabel: SKLabelNode!
    var playerTwoLabel: SKLabelNode!
    
    let TITLE_LABEL_HEIGHT = CGFloat(110)
    
    let NAME_TO_BOARD_RATIO = CGFloat(3.0/7.0)
    
    var gvc: GameViewController!
    
    var turnIndicator: SKShapeNode!
    
    //var deActivated: Bool = false
    
    //only to be used when gameType == .LocalSinglePlayer
    var isAIFirst: Bool!
    var aiDifficulty: AIDifficulty!
    
    //var suspended: Bool = false
    
    var aiCommunicationAgent: AICommunicationAgent = AICommunicationAgent()
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = .init(red: CGFloat(0xd1)/255.0, green: CGFloat(0xff)/255.0, blue: CGFloat(0xfa)/255.0, alpha: 1.0)
        
        if gameType == .LocalMultiplayer{
            
            let p1 = Player(ID: 1, name: playerOneName, inputType: .UI)
            let p2 = Player(ID: 2, name: playerTwoName, inputType: .UI)
            
            
            game = Game(initialRows: 6, initialCols: 7,
                        playerOne: p1,
                        playerTwo: p2)
            
        }
        if gameType == .LocalSinglePlayer {
            let p1 = Player(ID: 1, name: playerOneName, inputType: isAIFirst ? .AI : .UI)
            let p2 = Player(ID: 2, name: playerTwoName, inputType: isAIFirst ? .UI : .AI)
            
            game = Game(initialRows: 6, initialCols: 7,
                        playerOne: p1,
                        playerTwo: p2)
            
            
        }
        if gameType == .OnlineLive {
            let me = Player(ID: 1, name: MultiplayerCommunicationAgent.main.currentUser!.username, inputType: .UI)
            let them = Player(ID: 2, name: MultiplayerCommunicationAgent.main.otherUser!.username, inputType: .Server)
            
            game = Game(initialRows: 6,
                        initialCols: 7,
                        playerOne: MultiplayerCommunicationAgent.main.isSelfPlayerOne! ? me : them,
                        playerTwo: MultiplayerCommunicationAgent.main.isSelfPlayerOne! ? them : me)
            
            MultiplayerCommunicationAgent.main.game = game
            
        }
        
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
        
        titleLabel = SKSpriteNode(imageNamed: "g4")
        titleLabel.size = CGSize(width: TITLE_LABEL_HEIGHT * 137.0/84.0, height: TITLE_LABEL_HEIGHT)
        titleLabel.position = CGPoint(x: 0,y:  size.height/2 - 2*50.0)
        
        /*
        titleLabel = SKLabelNode()
        titleLabel.fontName = "Helvetica"
        titleLabel.text = "Gravity Four"
        adjustLabelFontSizeToFitRect(labelNode: titleLabel, rect: CGRect(x: -size.width/2,
                                                                         y: size.height/2 - 2*TITLE_LABEL_HEIGHT,
                                                                         width: size.width,
                                                                         height: TITLE_LABEL_HEIGHT))*/
        self.addChild(titleLabel)
        
        goBackButton = GoBackButton(gameScene: self)
        goBackButton.position = CGPoint(x: -size.width/2 + 50.0/2 + 15, y: size.height/2 - 50.0)
        goBackButton.isUserInteractionEnabled = true
        
        self.addChild(goBackButton)
        restartButton = RestartButton(gameScene: self)
        restartButton.position = CGPoint(x: size.width/2 - 50.0/2 - 15, y: size.height/2 - 50.0)
        restartButton.isUserInteractionEnabled = true
        
        if gameType == .LocalMultiplayer || gameType == .LocalSinglePlayer {
            self.addChild(restartButton)
        }
        
        
        playerOneLabel = SKLabelNode()
        playerOneLabel.fontName = "Helvetica"
        playerOneLabel.fontColor = .black
        playerOneLabel.text = game.playerOne.name
        let p1labelRect = CGRect(x: -board.width/2,
                                 y: board.width/2 + board.cellWidth,
                                 width: NAME_TO_BOARD_RATIO * board.width, height: 50)
        adjustLabelFontSizeToFitRect(labelNode: playerOneLabel, rect: p1labelRect)
        self.addChild(playerOneLabel)
        
        playerTwoLabel = SKLabelNode()
        playerTwoLabel.fontName = "Helvetica"
        playerTwoLabel.fontColor = .black
        playerTwoLabel.text = game.playerTwo.name
        let p2labelRect = CGRect(x: -board.width/2 + (1.0 - NAME_TO_BOARD_RATIO)*board.width,
                                 y: board.width/2 + board.cellWidth,
                                 width: NAME_TO_BOARD_RATIO * board.width, height: 50)
        adjustLabelFontSizeToFitRect(labelNode: playerTwoLabel, rect: p2labelRect)
        self.addChild(playerTwoLabel)
        
        var vsLabel = SKLabelNode()
        vsLabel.fontName = "Apple Chancery"
        vsLabel.fontColor = .black
        
        
        let maxw = max(playerOneLabel.frame.width, playerTwoLabel.frame.width)
        let maxh = max(playerOneLabel.frame.height, playerTwoLabel.frame.height)
        
        let xscaleFactor = CGFloat(1.1)
        let yscaleFactor = CGFloat(1.5)
        
        
        turnIndicator = SKShapeNode(rect: CGRect(x: -maxw*xscaleFactor/2,
                                                 y: -maxh*yscaleFactor/2,
                                                 width: maxw*xscaleFactor,
                                                 height: maxh*yscaleFactor),
                                    cornerRadius: 5)
        turnIndicator.fillColor = .init(red: 1, green: 0, blue: 0, alpha: 0.3)
        turnIndicator.zPosition = -10
        turnIndicator.position = CGPoint(x: playerOneLabel.frame.midX, y: playerOneLabel.frame.midY)
        self.addChild(turnIndicator)
        
        
        /*
        
        turnIndicator = PieceNode(player: game.playerOne, game: game, board: board, flipped: false)
        turnIndicator.xScale = 0.5
        turnIndicator.yScale = 0.5
        
        turnIndicator.position = CGPoint(x: playerOneLabel.position.x,
                                         y: playerOneLabel.position.y + 50*1.4)
        turnIndicator.physicsBody?.isDynamic = false
        self.addChild(turnIndicator)*/
        
        startTurn()
    }
    
    func startTurn(){
        let player = game.currentPlayer
        
        switch player.inputType {
        case .UI:
            //Enable the board UI
            //self.deActivated = false
            //if !suspended {
                activateInteraction()
            //}
        case .AI:
            //self.deActivated = true
            deactivateInteraction()
            fetchAIMove()
        case .Server:
            //self.deActivated = true
            deactivateInteraction()
            fetchServerMove()
        }
    }
    
    func fetchAIMove(){
        self.aiCommunicationAgent.getMove(for: game, difficulty: aiDifficulty){move in
            self.executeMove(move)
        }
    }
    
    func fetchServerMove(){
        MultiplayerCommunicationAgent.main.getOpponentMove{ move in
            self.executeMove(move)
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
        //suspended = true
        
        self.run(SKAction.wait(forDuration: duration)){
            //if !self.deActivated{
                self.children.forEach{$0.isUserInteractionEnabled = true}
            //}
            //self.suspended = false
        }
    }
    
    func deactivateInteraction(){
        self.children.forEach{$0.isUserInteractionEnabled = false}
        self.goBackButton.isUserInteractionEnabled = true
        self.restartButton.isUserInteractionEnabled = true
        
    }
    
    func activateInteraction(){
        self.children.forEach{$0.isUserInteractionEnabled = true}
    }
    
    func executeMove(_ move: Move){
        switch move {
        case let .drop(col):
            executeDrop(in: col)
        case let .rotate(dir):
            executeRotation(dir: dir)
        }
        
        _ = game.makeMove(move: move)
        toggleIndicator()
        //note that makeMove has already been called, so if the user made a move, then game.currentPlayer is the online player
        if game.currentPlayer.inputType == .Server {
            MultiplayerCommunicationAgent.main.reportMove()
        }
    }
    
    func executeDrop(in col: Int){
        suspendInteraction(for: 1)
        
        let newPiece = PieceNode(player: game.currentPlayer, game: game, board: board, flipped: board.sideWays)
        let absoluteCoords = CGPoint(x: -board.width/2 + board.cellWidth/2 + board.cellWidth * CGFloat(col),
                                     y: board.height/2 + board.cellWidth/2)
        newPiece.position = board.relativeCoords(from: absoluteCoords)
        
        board.pieces.append(newPiece)
        board.addChild(newPiece)

        checkWin(after: 1)
    
    }
    
    func executeRotation(dir: Move.Direction){
        suspendInteraction(for: 2)
        switch dir {
        case .left:
            board.rotateLeft()
        case .right:
            board.rotateRight()
        }
        
        checkWin(after: 2)

    }
    
    func toggleIndicator(){
        let newPos = CGPoint(x: -turnIndicator.position.x, y: turnIndicator.position.y)
        //turnIndicator.run(SKAction.move(to: CGPoint(x: 0, y: turnIndicator.position.y), duration: 0.5))
        turnIndicator.run(SKAction.fadeOut(withDuration: 0.5)){
            self.turnIndicator.removeFromParent()
            if self.game.currentPlayer == self.game.playerOne{
                self.turnIndicator.fillColor = .init(red: 1, green: 0, blue: 0, alpha: 0.3)
            }
            else{
                self.turnIndicator.fillColor = .init(red: 0, green: 0, blue: 0, alpha: 0.3)
            }
            self.turnIndicator.alpha = 0
            
            
            self.addChild(self.turnIndicator)
            //self.turnIndicator.run(SKAction.move(to: newPos, duration: 0.5))
            self.turnIndicator.position=newPos
            self.turnIndicator.run(SKAction.fadeIn(withDuration: 0.5)){
                
                //self.startTurn()
                
            }
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
            let isTie: Bool
            if p1wins.count > 0 && p2wins.count > 0 {
                drawWinResult(p1wins[0])
                drawWinResult(p2wins[0])
                showWinLabel("It's a Tie!")
                isTie = true
            }
            else{
                let winResult = results[0]
                drawWinResult(winResult)
                showWinLabel("\(winResult.player.name) wins!")
                isTie = false
            }
            if gameType == .OnlineLive {
                MultiplayerCommunicationAgent.main.reportEndGame(isTie: isTie)
            }
        }
        else if game.isBoardFull() {
            showWinLabel("It's a Tie!")
            deactivateInteraction()
            if gameType == .OnlineLive {
                MultiplayerCommunicationAgent.main.reportEndGame(isTie: true)
            }
        }
        else{
            startTurn()
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
        winNode.strokeColor = .white
        winNode.lineWidth = 10
        winNode.alpha = 0
        winNode.lineCap = .round

        self.addChild(winNode)
        winNode.zPosition = 200
        winNode.run(SKAction.fadeIn(withDuration: 2))
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}

