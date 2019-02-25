//
//  GameViewController.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/15/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase
import FirebaseAuth

class GameViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    
    var playerOneName = ""
    var playerTwoName = ""
    var gameType: GameType!
    
    var isAIFirst: Bool!
    var aiDifficulty: AIDifficulty!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                
                let scene = scene as! GameScene
                
                scene.playerOneName = playerOneName
                scene.playerTwoName = playerTwoName
                scene.gameType = gameType
                scene.gvc = self
                scene.isAIFirst = isAIFirst
                scene.aiDifficulty = self.aiDifficulty
                // Set the scale mode to scale to fit the window
                //scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            // ...
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}
