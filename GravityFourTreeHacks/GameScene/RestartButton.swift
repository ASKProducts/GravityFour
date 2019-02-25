//
//  RestartButton.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import UIKit
import SpriteKit

class RestartButton: SKSpriteNode {
    let gameScene: GameScene
    init(gameScene: GameScene){
        self.gameScene = gameScene
        
        
        super.init(texture: SKTexture(imageNamed: "Restart"), color: .clear, size: CGSize(width: 50, height: 50))
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first!.location(in: self)
        if -size.width/2 < loc.x && loc.x < size.width/2{
            if -size.height/2 < loc.y && loc.y < size.height/2 {
                gameScene.removeFromParent()
                if let scene = SKScene(fileNamed: "GameScene") {
                    
                    let scene = scene as! GameScene
                    
                    scene.playerOneName = gameScene.playerOneName
                    scene.playerTwoName = gameScene.playerTwoName
                    scene.gameType = gameScene.gameType
                    scene.gvc = gameScene.gvc
                    scene.isAIFirst = gameScene.isAIFirst
                    scene.aiDifficulty = gameScene.aiDifficulty
                    // Set the scale mode to scale to fit the window
                    //scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    (scene.gvc.view as! SKView).presentScene(scene)
                }
                
            }
        }
        
    }
}
