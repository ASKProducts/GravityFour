//
//  MainMenuViewController.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import UIKit
import SwiftEntryKit
import QuickLayout

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func playLocalGame(_ sender: Any) {
        
        
        var attributes = EKAttributes.centerFloat
        //attributes.entryBackground = .gradient(gradient: .init(colors: [.cyan, .cyan], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenBackground = .color(color: UIColor(white: 0.5, alpha: 0.5))
        
        //attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        //attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.scroll = .disabled
        attributes.positionConstraints.maxSize = .init(width: .intrinsic, height: .intrinsic)
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: .lightGray)
        //attributes.exitAnimation = .none
        
        let title = EKProperty.LabelContent(text: "Play Local Game", style: .init(font: .systemFont(ofSize: 40), color: .black))
        
        let p1namePlaceHolder = EKProperty.LabelContent(text: "Player One", style: .init(font: .systemFont(ofSize: 20), color: .darkGray))
        let p1name = EKProperty.TextFieldContent(keyboardType: .default,
                                                 placeholder: p1namePlaceHolder,
                                                 textStyle: .init(font: .systemFont(ofSize: 20), color: .black),
                                                 isSecure: false, leadingImage: nil, bottomBorderColor: .gray)
        
        
        let p2namePlaceHolder = EKProperty.LabelContent(text: "Player Two", style: .init(font: .systemFont(ofSize: 20), color: .darkGray))
        let p2name = EKProperty.TextFieldContent(keyboardType: .default,
                                                 placeholder: p2namePlaceHolder,
                                                 textStyle: .init(font: .systemFont(ofSize: 20), color: .black),
                                                 isSecure: false, leadingImage: nil, bottomBorderColor: .gray)
        
        let buttonLabel = EKProperty.LabelContent(text: "Play!", style: .init(font: .systemFont(ofSize: 40), color: .blue))
        let button = EKProperty.ButtonContent(label: buttonLabel,
                                              backgroundColor: .gray, highlightedBackgroundColor: .darkGray,
                                              contentEdgeInset: 1.0){
                                                NSLog("%@", p2name.textContent)
        }
        
        let formView = EKFormMessageView(with: title, textFieldsContent: [p1name, p2name], buttonContent: button)
        
        attributes.lifecycleEvents.willDisappear = {
            formView.extractTextFieldsContent()
            
            let playerOneName = p1name.textContent == "" ? "Player One" : p1name.textContent
            let playerTwoName = p2name.textContent == "" ? "Player Two" : p2name.textContent
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let gameViewController = storyBoard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
            gameViewController.playerOneName = playerOneName
            gameViewController.playerTwoName = playerTwoName
            gameViewController.gameType = GameType.LocalMultiplayer
            self.present(gameViewController, animated: true, completion: nil)
        }
        
        SwiftEntryKit.display(entry: formView, using: attributes)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
