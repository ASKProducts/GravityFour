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
import FirebaseAuth
import GoogleSignIn

class MainMenuViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        loginStatusLabel.adjustsFontSizeToFitWidth = true
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var loginStatusLabel: UILabel!
    /*func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            return
        }
        print("POOOOOP")
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
        }
    }*/
    
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBAction func playLocalGame(_ sender: Any) {
        
        
        var attributes = EKAttributes.centerFloat
        //attributes.entryBackground = .gradient(gradient: .init(colors: [.cyan, .cyan], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenBackground = .color(color: .init(red: CGFloat(0xd1)/255.0, green: CGFloat(0xff)/255.0, blue: CGFloat(0xfa)/255.0, alpha: 1.0))
        
        //attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        //attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.scroll = .disabled
        attributes.positionConstraints.maxSize = .init(width: .intrinsic, height: .intrinsic)
        attributes.displayDuration = .infinity
        //attributes.screenBackground = .color(color: .lightGray)
        //attributes.exitAnimation = .none
        
        var title = EKProperty.LabelContent(text: "Pass & Play", style: .init(font: .systemFont(ofSize: 40), color: .black))
        title.style.alignment = .center
        
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
        
        let buttonLabel = EKProperty.LabelContent(text: "Play!", style: .init(font: .systemFont(ofSize: 40), color: .white))
        let button = EKProperty.ButtonContent(label: buttonLabel,
                                              backgroundColor: .init(red: 0, green: 0.2, blue: 0.6, alpha: 1 ),
                                              highlightedBackgroundColor: .init(red: 0, green: 0.2, blue: 0.2, alpha: 1 ),
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
    
    @IBAction func playAIGame(_ sender: Any) {
        
        var attributes = EKAttributes.centerFloat
        //attributes.entryBackground = .gradient(gradient: .init(colors: [.cyan, .cyan], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenBackground = .color(color: .init(red: CGFloat(0xd1)/255.0, green: CGFloat(0xff)/255.0, blue: CGFloat(0xfa)/255.0, alpha: 1.0))
        
        //attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        //attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.scroll = .disabled
        attributes.positionConstraints.maxSize = .init(width: .intrinsic, height: .intrinsic)
        attributes.displayDuration = .infinity
        //attributes.screenBackground = .color(color: .lightGray)
        attributes.entryInteraction = .absorbTouches
        
        var initialTitle = EKProperty.LabelContent(text: "Play Against the AI", style: .init(font: .systemFont(ofSize: 35), color: .black))
        initialTitle.style.alignment = NSTextAlignment.center
        var initialDesc = EKProperty.LabelContent(text: "Choose a Difficulty", style: .init(font: .systemFont(ofSize: 30), color: .black))
        initialDesc.style.alignment = NSTextAlignment.center
        var easyTitle = EKProperty.LabelContent(text: "Easy", style: .init(font: .systemFont(ofSize: 40), color: .black))
        easyTitle.style.alignment = NSTextAlignment.center
        var medTitle = EKProperty.LabelContent(text: "Medium", style: .init(font: .systemFont(ofSize: 40), color: .black))
        medTitle.style.alignment = NSTextAlignment.center
        var hardTitle = EKProperty.LabelContent(text: "Hard", style: .init(font: .systemFont(ofSize: 40), color: .black))
        hardTitle.style.alignment = NSTextAlignment.center
        var extremeTitle = EKProperty.LabelContent(text: "Extreme!", style: .init(font: .systemFont(ofSize: 40), color: .black))
        extremeTitle.style.alignment = NSTextAlignment.center
        
        
        let nothingLabel = EKProperty.LabelContent(text: "", style: .init(font: .systemFont(ofSize: 0), color: .black))
        let emptyImage = EKProperty.ImageContent(imageName: "RedEmptyCircle")
        let fullImage = EKProperty.ImageContent(imageName: "RedCircle")
        
        
        let rankingItems: [EKProperty.EKRatingItemContent] =
            [EKProperty.EKRatingItemContent(title: easyTitle,
                                            description: nothingLabel,
                                            unselectedImage: emptyImage,
                                            selectedImage: fullImage),
             EKProperty.EKRatingItemContent(title: medTitle,
                                            description: nothingLabel,
                                            unselectedImage: emptyImage,
                                            selectedImage: fullImage),
             EKProperty.EKRatingItemContent(title: hardTitle,
                                            description: nothingLabel,
                                            unselectedImage: emptyImage,
                                            selectedImage: fullImage),
             EKProperty.EKRatingItemContent(title: extremeTitle,
                                            description: nothingLabel,
                                            unselectedImage: emptyImage,
                                            selectedImage: fullImage)]
        
        let meFirstLabel = EKProperty.LabelContent(text: "Me First!", style: .init(font: .systemFont(ofSize: 20), color: .white))
        
        var meFirstButton = EKProperty.ButtonContent(label: meFirstLabel, backgroundColor: .init(red: 0, green: 0.2, blue: 0.6, alpha: 1 ),
                                                     highlightedBackgroundColor: .init(red: 0, green: 0.2, blue: 0.2, alpha: 1 ))
        
        let aiFirstLabel = EKProperty.LabelContent(text: "AI First!", style: .init(font: .systemFont(ofSize: 20), color: .white))
        
        var aiFirstButton = EKProperty.ButtonContent(label: aiFirstLabel, backgroundColor: .init(red: 0, green: 0.2, blue: 0.6, alpha: 1 ),
                                                     highlightedBackgroundColor: .init(red: 0, green: 0.2, blue: 0.2, alpha: 1 ))
        
        var ratingsMessage: EKRatingMessage? = nil
        
        meFirstButton.action = {
            print("ME FIRST PRESSED")
            let difficulty: AIDifficulty
            switch ratingsMessage!.selectedIndex! {
            case 0:
                difficulty = .easy
            case 1:
                difficulty = .medium
            case 2:
                difficulty = .hard
            case 3:
                difficulty = .extreme
                
            default:
                fatalError()
            }
            SwiftEntryKit.dismiss()
            self.loadAI(aiFirst: false, difficulty: difficulty)
        }
        
        aiFirstButton.action = {
            print("AI FIRST PRESSED")
            let difficulty: AIDifficulty
            switch ratingsMessage!.selectedIndex! {
            case 0:
                difficulty = .easy
            case 1:
                difficulty = .medium
            case 2:
                difficulty = .hard
            case 3:
                difficulty = .extreme
                
            default:
                fatalError()
            }
            SwiftEntryKit.dismiss()
            self.loadAI(aiFirst: true, difficulty: difficulty)
        }
        
        let buttonBar = EKProperty.ButtonBarContent(with: meFirstButton, aiFirstButton,
                                                        separatorColor: .black,
                                                        expandAnimatedly: true)
        
        ratingsMessage = EKRatingMessage(initialTitle: initialTitle,
                                             initialDescription: initialDesc,
                                             ratingItems: rankingItems,
                                             buttonBarContent: buttonBar)
        let ratingsView = EKRatingMessageView(with: ratingsMessage!)
        
    
        
        attributes.lifecycleEvents.willDisappear = {
            print("POOOOOP")
        }
        
        SwiftEntryKit.display(entry: ratingsView, using: attributes)
        
        
        
        /*
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let gameViewController = storyBoard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameViewController.playerOneName = "User"
        gameViewController.playerTwoName = "AI"
        gameViewController.gameType = GameType.LocalSinglePlayer
        gameViewController.isAIFirst = false
        self.present(gameViewController, animated: true, completion: nil)*/
    }
    
    func loadAI(aiFirst: Bool, difficulty: AIDifficulty){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let gameViewController = storyBoard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        if !aiFirst{
            gameViewController.playerOneName = "User"
            gameViewController.playerTwoName = "AI"
        }
        else{
            gameViewController.playerOneName = "AI"
            gameViewController.playerTwoName = "User"
        }
        gameViewController.gameType = GameType.LocalSinglePlayer
        gameViewController.isAIFirst = aiFirst
        gameViewController.aiDifficulty = difficulty
        self.present(gameViewController, animated: true, completion: nil)
    }
    @IBAction func playOnlineMultiplayer(_ sender: Any) {
        var attributes = EKAttributes.centerFloat
        //attributes.entryBackground = .gradient(gradient: .init(colors: [.cyan, .cyan], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenBackground = .color(color: .init(red: CGFloat(0xd1)/255.0, green: CGFloat(0xff)/255.0, blue: CGFloat(0xfa)/255.0, alpha: 1.0))
        
        //attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        //attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.scroll = .disabled
        attributes.positionConstraints.maxSize = .init(width: .intrinsic, height: .intrinsic)
        attributes.displayDuration = .infinity
        //attributes.screenBackground = .color(color: .lightGray)
        attributes.entryInteraction = .absorbTouches
        
        var titleLabel = EKProperty.LabelContent(text: "Looking for an Opponent...", style: .init(font: .systemFont(ofSize: 35), color: .black))
        titleLabel.style.alignment = NSTextAlignment.center
        let nothingLabel = EKProperty.LabelContent(text: "", style: .init(font: .systemFont(ofSize: 0), color: .black))
        let waitingView = EKPopUpMessage(title: titleLabel, description: nothingLabel,
                                         button: .init(label: nothingLabel, backgroundColor: .clear, highlightedBackgroundColor: .clear)) {
                                            
        }
        let waiting = EKPopUpMessageView(with: waitingView)
        SwiftEntryKit.display(entry: waiting, using: attributes)
        
        MultiplayerCommunicationAgent.main.enterQueue { (otherUser, isSelfFirst) in
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let gameViewController = storyBoard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
            gameViewController.gameType = GameType.OnlineLive
            SwiftEntryKit.dismiss()
            self.present(gameViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func loginGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func logout(_ sender: Any) {
        GIDSignIn.sharedInstance()!.signOut()
        //try? Auth.auth().signOut()
        loginStatusLabel.text = "Not Logged In"
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("HI")
            print(auth)
            print(user)
            if user != nil{
                print(user?.displayName)
                
                MultiplayerCommunicationAgent.main.currentUser = User(ID: user!.uid, username: user!.displayName!)
                
                self.loginStatusLabel.text = "Logged in as \(user!.displayName!)"
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

}
