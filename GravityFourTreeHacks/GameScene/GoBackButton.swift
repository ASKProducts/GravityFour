//
//  GoBackButton.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import UIKit
import SpriteKit
class GoBackButton: SKSpriteNode {
    let gameScene: GameScene
    init(gameScene: GameScene){
        self.gameScene = gameScene
        
        
        super.init(texture: SKTexture(imageNamed: "GoBack"), color: .clear, size: CGSize(width: gameScene.TITLE_LABEL_HEIGHT, height: gameScene.TITLE_LABEL_HEIGHT))
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first!.location(in: self)
        if -size.width/2 < loc.x && loc.x < size.width/2{
            if -size.height/2 < loc.y && loc.y < size.height/2 {
                gameScene.gvc.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
}

