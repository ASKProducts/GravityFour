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
    
    override func didMove(to view: SKView) {
        if gameType == .LocalMultiplayer{
            game = Game(initialRows: 6, initialCols: 7,
                        playerOne: Player(ID: 1, name: playerOneName),
                        playerTwo: Player(ID: 2, name: playerTwoName))
            
            
        }
        
    }
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
