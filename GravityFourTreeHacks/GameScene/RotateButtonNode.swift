//
//  RotateButtonNode.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import UIKit
import SpriteKit

class RotateButtonNode: SKSpriteNode {
    
    let ROTATE_LEFT_IMAGE = "RotateLeft"
    let ROTATE_RIGHT_IMAGE = "RotateRight"
    
    let BOARD_TO_ROTATE_BUTTON_RATIO = CGFloat(0.3)
    
    var gameScene: GameScene
    
    var highLighter: SKShapeNode!
    
    var dir: Move.Direction
    
    init(dir: Move.Direction, board: BoardNode, gameScene: GameScene) {
        let texture = SKTexture(imageNamed: dir == .left ? ROTATE_LEFT_IMAGE : ROTATE_RIGHT_IMAGE)

        self.dir = dir
        self.gameScene = gameScene
        super.init(texture: texture, color: .clear, size: CGSize(width: board.width * BOARD_TO_ROTATE_BUTTON_RATIO,
                                                                 height: board.width * BOARD_TO_ROTATE_BUTTON_RATIO))
        
        self.highLighter = SKShapeNode(rectOf: self.size)
        highLighter.strokeColor = .clear
        highLighter.fillColor = board.HIGHLIGHTER_FOCUS_COLOR
        highLighter.isHidden = true
        self.addChild(highLighter)
        
        isUserInteractionEnabled = true

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        highLighter.isHidden = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first!.location(in: self)
        if -size.width/2 < loc.x && loc.x < size.width/2{
            if -size.height/2 < loc.y && loc.y < size.height/2 {
                highLighter.isHidden = false
                return
            }
        }
        highLighter.isHidden = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first!.location(in: self)
        highLighter.isHidden = true
        if -size.width/2 < loc.x && loc.x < size.width/2{
            if -size.height/2 < loc.y && loc.y < size.height/2 {
                gameScene.executeRotation(dir: self.dir)
                return
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
