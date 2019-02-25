//
//  BoardNode.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import UIKit
import SpriteKit

class BoardNode: SKNode {

    var width: CGFloat
    let game: Game
   
    let ROTATION_DURATION = 1.0
    let HIGHLIGHTER_FOCUS_COLOR = UIColor(white: 0.5, alpha: 0.7)
    
    var activeInnerWalls: [SKShapeNode]
    var inactiveInnerWalls: [SKShapeNode]
    
    var topWall: SKShapeNode!
    var bottomWall: SKShapeNode!
    var leftWall: SKShapeNode!
    var rightWall: SKShapeNode!
    
    var pieces: [PieceNode]
    
    var totalAngle: CGFloat = 0.0
    var sideWays: Bool = false
    
    var highlighters: [SKShapeNode]
    var cellWidth: CGFloat
   
    var tempPiece: PieceNode? = nil
    
    var height: CGFloat {
        return width * CGFloat(game.numRows)/CGFloat(game.numCols)
    }
    
    var gameScene: GameScene
    
    var boardMask: SKSpriteNode
    
    let BOARD_MASK_WIDTH_RATIO = CGFloat(13.15/12.54)
    
    init(game: Game, width: CGFloat, gameScene: GameScene) {
        self.width = width
        self.cellWidth = width / CGFloat(game.numCols)
        self.game = game
        
        self.activeInnerWalls = []
        self.inactiveInnerWalls = []
        self.pieces = []
        
        self.highlighters = []
        self.gameScene = gameScene
        
        self.totalAngle = 0.0
        
        boardMask = SKSpriteNode(imageNamed: "BoardMask")
        
        super.init()
        
        self.isUserInteractionEnabled = true
        
        for i in 0...(game.numCols){
            let wallPath = CGMutablePath()
            wallPath.addLines(between: [CGPoint(x: 0, y: -height/2),
                                        CGPoint(x: 0, y: height/2)])
            let wall = SKShapeNode(path: wallPath)
            wall.physicsBody = SKPhysicsBody(edgeChainFrom: wallPath)
            wall.physicsBody?.isDynamic = false
            wall.position = CGPoint(x: -width/2 + CGFloat(i)*cellWidth, y: 0)
            if i == 0 {
                self.leftWall = wall
            }
            else if i == game.numCols{
                self.rightWall = wall
            }
            else{
                self.activeInnerWalls.append(wall)
            }
            self.addChild(wall)
        }
        
        for i in 0...(game.numRows){
            let wallPath = CGMutablePath()
            wallPath.addLines(between: [CGPoint(x: -width/2, y: 0),
                                        CGPoint(x: width/2, y: 0)])
            let wall = SKShapeNode(path: wallPath)
            wall.physicsBody = SKPhysicsBody(edgeChainFrom: wallPath)
            wall.physicsBody?.isDynamic = false
           // wall.physicsBody?.collisionBitMask = 0
           // wall.physicsBody?.categoryBitMask = 0
 
            wall.position = CGPoint(x: 0, y: -height/2 + CGFloat(i)*cellWidth)
            if i == game.numRows{
                self.topWall = wall
                //self.topWall.physicsBody?.collisionBitMask = 0xFFFFFFFF
                self.topWall.strokeColor = .red
            }
            else if i == 0{
                self.bottomWall = wall
                //self.bottomWall.physicsBody?.collisionBitMask = 0xFFFFFFFF
                //self.bottomWall.physicsBody?.categoryBitMask = 0xFFFFFFFF
                self.bottomWall.strokeColor = .blue
            }
            else{
                self.inactiveInnerWalls.append(wall)
            }
            self.addChild(wall)
        }
        
        boardMask.size = CGSize(width: width * BOARD_MASK_WIDTH_RATIO,
                                height: height * BOARD_MASK_WIDTH_RATIO)
        self.addChild(boardMask)
        boardMask.zPosition = 100
        
        resetWallCollisions()
        refreshHighlighters()
        
        
    }
    
    func relativeCoords(from absolute: CGPoint) -> CGPoint {
        return CGPoint(x: cos(totalAngle)*absolute.x - sin(totalAngle)*absolute.y,
                       y: sin(totalAngle)*absolute.x + cos(totalAngle)*absolute.y)
    }
    
    func rotateLeft() {
        //first off, freeze all the piece
        for piece in pieces{
            piece.physicsBody?.isDynamic = false
        }
        //isUserInteractionEnabled = false
        self.run(SKAction.rotate(byAngle: CGFloat.pi/2, duration: ROTATION_DURATION)){
            //now we activate all inactive walls and vice versa
            
            (self.activeInnerWalls, self.inactiveInnerWalls) = (self.inactiveInnerWalls, self.activeInnerWalls)
            
            (self.topWall, self.leftWall, self.bottomWall, self.rightWall) = (self.rightWall, self.topWall, self.leftWall, self.bottomWall)
            
            self.resetWallCollisions()
            
            for piece in self.pieces{
                piece.turnPhysicsBody()
                piece.physicsBody?.isDynamic = true
            }
            //self.isUserInteractionEnabled = true
            self.totalAngle -= CGFloat.pi/2
        
            self.sideWays = !self.sideWays
            
            self.width = self.cellWidth * CGFloat(self.game.numCols)
            self.refreshHighlighters()
        }
        
    }
    
    func rotateRight() {
        //first off, freeze all the piece
        for piece in pieces{
            piece.physicsBody?.isDynamic = false
        }
        //isUserInteractionEnabled = false
        self.run(SKAction.rotate(byAngle: -CGFloat.pi/2, duration: ROTATION_DURATION)){
            //now we activate all inactive walls and vice versa
            
            
            (self.activeInnerWalls, self.inactiveInnerWalls) = (self.inactiveInnerWalls, self.activeInnerWalls)
            
            (self.topWall, self.leftWall, self.bottomWall, self.rightWall) = (self.leftWall, self.bottomWall, self.rightWall, self.topWall)
            
            self.resetWallCollisions()
            
            for piece in self.pieces{
                piece.turnPhysicsBody()
                piece.physicsBody?.isDynamic = true
            }
            
            //self.isUserInteractionEnabled = true
            self.totalAngle += CGFloat.pi/2
            
            self.sideWays = !self.sideWays
            
            self.width = self.cellWidth * CGFloat(self.game.numCols)
            self.refreshHighlighters()
        }
    
        
    }
    
    
    
    func resetWallCollisions() {
        deactivateCollisions(wall: self.topWall)
        
        activateCollisions(wall: self.bottomWall)
        activateCollisions(wall: self.rightWall)
        activateCollisions(wall: self.leftWall)
        
        for wall in self.activeInnerWalls{
            activateCollisions(wall: wall)
        }
        for wall in self.inactiveInnerWalls{
            deactivateCollisions(wall: wall)
        }
    }
    
    func activateCollisions(wall: SKShapeNode) {
        //wall.physicsBody = SKPhysicsBody(edgeChainFrom: wall.path!)
        //wall.physicsBody?.isDynamic = false
        wall.physicsBody?.contactTestBitMask = 1
        wall.physicsBody?.categoryBitMask = 1
        wall.physicsBody?.collisionBitMask = 1
        
    }
    
    func deactivateCollisions(wall: SKShapeNode){
        wall.physicsBody?.contactTestBitMask = 0
        wall.physicsBody?.categoryBitMask = 0
        wall.physicsBody?.collisionBitMask = 0
    }
    
    
    
    func refreshHighlighters() {
        for highlighter in highlighters {
            highlighter.removeFromParent()
        }
        highlighters.removeAll()
        
        for c in 0..<game.numCols {
            let oneCorner = relativeCoords(from: CGPoint(x: -width/2 + CGFloat(c) * cellWidth,
                                                        y: -height/2))
            
            let otherCorner = relativeCoords(from: CGPoint(x: -width/2 + CGFloat(c) * cellWidth + cellWidth,
                                                           y: height/2))
            
            let origin = CGPoint(x: min(oneCorner.x, otherCorner.x), y: min(oneCorner.y, otherCorner.y))
            let w = abs(oneCorner.x - otherCorner.x)
            let h = abs(oneCorner.y - otherCorner.y)
            
            //let s = !sideWays ? CGSize(width: cellWidth, height: cellWidth * CGFloat(game.numRows)) : CGSize(width: cellWidth*CGFloat(game.numRows), height: -cellWidth )
            let highlighter = SKShapeNode(rect: CGRect(x: origin.x,
                                                       y: origin.y,
                                                       width: w,
                                                       height: h))
            highlighter.strokeColor = .clear
            highlighter.fillColor = .clear
            self.highlighters.append(highlighter)
            self.addChild(highlighter)
        }
    }
    
    func unfocusHighlighters(){
        for h in highlighters {
            h.fillColor = .clear
        }
    }
    
    func focusCol(_ col: Int){
        unfocusHighlighters()
        highlighters[col].fillColor = HIGHLIGHTER_FOCUS_COLOR
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first!.location(in: gameScene)
        let col = Int(floor((loc.x + width/2)/cellWidth))
        focusCol(col)
        
        tempPiece = PieceNode(player: game.currentPlayer, game: game, board: self, flipped: sideWays)
        tempPiece?.physicsBody?.isDynamic = false
        let absoluteCoords = CGPoint(x: -width/2 + cellWidth/2 + cellWidth * CGFloat(col),
                                     y: height/2 * BOARD_MASK_WIDTH_RATIO + cellWidth/2)
        tempPiece?.position = relativeCoords(from: absoluteCoords)
        self.addChild(tempPiece!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first!.location(in: gameScene)
        let col = Int(floor((loc.x + width/2)/cellWidth))
        if col < 0 || col >= game.numCols || loc.y < -height/2 || loc.y > height/2{
            unfocusHighlighters()
            tempPiece?.isHidden = true
        }
        else{
            tempPiece?.isHidden = false
            let absoluteCoords = CGPoint(x: -width/2 + cellWidth/2 + cellWidth * CGFloat(col),
                                         y: height/2 * BOARD_MASK_WIDTH_RATIO + cellWidth/2)
            tempPiece?.position = relativeCoords(from: absoluteCoords)
            focusCol(col)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first!.location(in: gameScene)
        let col = Int(floor((loc.x + width/2)/cellWidth))
        tempPiece?.removeFromParent()
        tempPiece = nil
        unfocusHighlighters()
        if col < 0 || col >= game.numCols || loc.y < -height/2 || loc.y > height/2{
            return
        }
        else{
            if game.canMakeMove(move: .drop(col)){
                gameScene.executeMove(.drop(col))
            }
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
