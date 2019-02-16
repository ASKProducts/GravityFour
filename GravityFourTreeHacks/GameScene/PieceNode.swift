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
    
    
    let playerOneImage = "RedCircle"
    let playerTwoImage = "BlackCircle"
    
    
    init(player: Player, game: Game) {
        self.player = player
        self.game = game
        
        let texture = SKTexture(imageNamed: player == game.playerOne ? playerOneImage : playerTwoImage)
        super.init(texture: texture, color: .clear, size: CGSize.zero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
