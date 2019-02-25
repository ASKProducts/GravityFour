//
//  MultiplayerCommunicationAgent.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation
import Firebase

struct User{
    let ID: String
    let username: String
    
}

class MultiplayerCommunicationAgent {
   
    static var main = MultiplayerCommunicationAgent()
    
    var currentUser: User?
    var otherUser: User?
    var isSelfPlayerOne: Bool?
    var game: Game?
    
    var challengeToken: [String: Any]? = nil
    
    init() {
        
    }
    
    func login(username: String, password: String){
        
    }
    
    func logout(){
        
    }
    
    func postRequest(urlString: String, inputJSON: [String: Any], completion: @escaping ([String: Any]) -> ()) {
        
        let jsonData = try! JSONSerialization.data(withJSONObject: inputJSON, options: .prettyPrinted)
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else { fatalError("big error") }
            guard let data = data else { fatalError("no data") }
            do {
                //create json object from data
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { fatalError("bad json") }
                print(json)
                
                completion(json)
                
            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
        
    }
    
    //enters the game queue, and then asyncronously waits until paired and calls pairedCompletion when paired. The argument is the other user,
    func enterQueue(pairedCompletion: @escaping (_ other: User, _ isSelfPlayerOne: Bool) -> ()){
        //post to /api/match
        //post {uid: _}. will get {challenge: X}, where X is empty iff queue is empty
        //if X is nonempty, X = {"room": _, "playerOne": _, "playerTwo": _}
        //use firebase to query for palyer two's dislayname
        
        requestUntilMatched(delay: 2, pairedCompletion: pairedCompletion)
        
        
    }
    
    func requestUntilMatched(delay: TimeInterval, pairedCompletion: @escaping (_ other: User, _ isSelfPlayerOne: Bool) -> ()){
        let jsoninput = ["uid": MultiplayerCommunicationAgent.main.currentUser!.ID]
        postRequest(urlString: "https://us-central1-treehacks-2019.cloudfunctions.net/app/api/match",
                    inputJSON: jsoninput){json in
                        if json["challenge"] == nil{
                            fatalError("no challenge in json message")
                        }
                        if (json["challenge"] as! [String: Any]).count == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                                self.requestUntilMatched(delay: delay, pairedCompletion: pairedCompletion)
                            }
                        }
                        else{
                            MultiplayerCommunicationAgent.main.challengeToken = json
                            let p1uid = (json["challenge"]! as! [String: Any])["playerOne"]! as! String
                            let p2uid = (json["challenge"]! as! [String: Any])["playerTwo"]! as! String
                            let otherUID = p1uid == self.currentUser!.ID ? p2uid : p1uid
                            self.getNameFromUID(otherUID){name in
                                self.otherUser = User(ID: otherUID, username: name)
                                self.isSelfPlayerOne = p1uid == self.currentUser!.ID
                                pairedCompletion(self.otherUser!, p1uid == self.currentUser!.ID)
                            }
                            
                        }
        }
    }
    
    func getNameFromUID(_ uid: String, completion: @escaping (String) -> ()){
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.getDocument { (snapshot, err) in
            completion(snapshot!.get("display") as! String)
        }
    }
    
    //asynchronously gets the opponents move by querying a post request over and over again until
    func getOpponentMove(completion: @escaping (Move) -> ()){
        //send challenge token to api/play/moves
        //get back {"moves": list of moves}
        requestOppMove(delay: 2, completion: completion)
        
    }
    
    func requestOppMove(delay: TimeInterval, completion: @escaping (Move) -> ()){
        postRequest(urlString: "https://us-central1-treehacks-2019.cloudfunctions.net/app/api/play/moves",
                    inputJSON: challengeToken!){json in
                        let moves = json["moves"]! as! [Int]
                        if self.game!.turnHistory.count >= moves.count{
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                                self.requestOppMove(delay: delay, completion: completion)
                            }
                        }
                        else{
                            let responseInt = moves.last!
                            if 0 <= responseInt && responseInt < 7 {
                                completion(.drop(responseInt))
                            }
                            else if responseInt == 7 {
                                completion(.rotate(.right))
                            }
                            else if responseInt == 8 {
                                completion(.rotate(.left))
                            }
                        }
        }
    }
    
    //notify the server of the most recent move made (no need for parameter, all kept in game field)
    func reportMove(){
        //send to api/play
        //send {<challenge>, move: _, uid: _}
        
        let lastMove = game!.turnHistory.last!
        let m: Int
        switch lastMove {
        case let .drop(col):
            m = col
        case .rotate(.right):
            m = 7
        case .rotate(.left):
            m = 8
        }
        postRequest(urlString: "https://us-central1-treehacks-2019.cloudfunctions.net/app/api/play",
                    inputJSON: ["challenge": challengeToken!["challenge"]!, "move": m, "uid": currentUser!.ID]){json in
                        print(json)
                        print("booby")
                        //TODO if timing matters
        }
    }
    
    //NOTE: MAKE SURE TO RE-NIL ALL THE OPTIONAL SHIT
    func reportEndGame(isTie: Bool){
        //send to api/endGame
        //send {"uid":, _, "won": 1|0|0.5, <challenge>}
        
        var json: [String: Any] = [:]
        json["uid"] = currentUser!.ID
        if isTie{
            json["won"] = 0.5
        }
        else{
            if game!.winResults[0].player.name == currentUser!.username {
                json["won"] = 1.0
            }
            else{
                json["won"] = 0.0
            }
        }
        
        json["challenge"] = challengeToken!["challenge"]!
        
        postRequest(urlString: "https://us-central1-treehacks-2019.cloudfunctions.net/app/api/endGame",
                    inputJSON: json){json in
                        print(json)
        }
        
        otherUser = nil
        isSelfPlayerOne = nil
        game = nil
    }
    
}
