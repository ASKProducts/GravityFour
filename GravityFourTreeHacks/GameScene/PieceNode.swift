//
//  PieceNode.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import UIKit
import SpriteKit

class PieceNode: SKSpriteNode {

    var player: Player
    var game: Game
    
    var board: BoardNode
    
    let playerOneImage = "RedCircle"
    let playerTwoImage = "BlackCircle"
    
    let FILL_FRACTION = CGFloat(0.95)
    let OFFSET = CGFloat(2)
    
    var isWidthSmaller: Bool = true
    
    init(player: Player, game: Game, board: BoardNode, flipped: Bool) {
        self.player = player
        self.game = game
        self.board = board
        
        let texture = SKTexture(imageNamed: player == game.playerOne ? playerOneImage : playerTwoImage)
        super.init(texture: texture, color: .blue, size: CGSize(width: board.cellWidth*FILL_FRACTION, height: board.cellWidth*FILL_FRACTION))
        if !flipped{
            self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: board.cellWidth-OFFSET, height: board.cellWidth))
            isWidthSmaller = true
        }
        else{
            self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: board.cellWidth, height: board.cellWidth - OFFSET))
            isWidthSmaller = false
        }
    }
    
    func turnPhysicsBody() {
        if !isWidthSmaller{
            self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: board.cellWidth-OFFSET, height: board.cellWidth))
            isWidthSmaller = true
        }
        else{
            self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: board.cellWidth, height: board.cellWidth - OFFSET))
            isWidthSmaller = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
