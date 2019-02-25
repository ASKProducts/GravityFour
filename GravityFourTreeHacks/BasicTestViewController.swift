//
//  BasicTestViewController.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/15/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import UIKit

class BasicTestViewController: UIViewController {
    
    var game: Game!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        game = Game(initialRows: 6,
                    initialCols: 7,
                    playerOne: Player(ID: 1, name: "Player One", inputType: .UI),
                    playerTwo: Player(ID: 2, name: "Player Two", inputType: .UI))
        
        display.text = game.toString()
        winStatus.text = "\(game.winResults)"
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var display: UITextView!
    @IBOutlet weak var colControl: UISegmentedControl!
    
    @IBAction func drop(_ sender: Any) {
        _ = game.makeMove(move: .drop(colControl.selectedSegmentIndex))
        display.text = game.toString()
        checkWinner()
    }
    @IBAction func rotateLeft(_ sender: Any) {
        _ = game.makeMove(move: .rotate(.left))
        display.text = game.toString()
        checkWinner()
    }
    @IBAction func rotateRight(_ sender: Any) {
        _ = game.makeMove(move: .rotate(.right))
        display.text = game.toString()
        checkWinner()
    }
    @IBAction func restart(_ sender: Any) {
        game = Game(initialRows: 6,
                    initialCols: 7,
                    playerOne: Player(ID: 1, name: "Player One", inputType: .UI),
                    playerTwo: Player(ID: 2, name: "Player Two", inputType: .UI))
        
        display.text = game.toString()
        winStatus.text = "\(game.winResults)"
    }
    
    func checkWinner() {
        _ = game.checkWinner()
        winStatus.text = "\(game.winResults)"
    }
    
    @IBOutlet weak var winStatus: UITextView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
