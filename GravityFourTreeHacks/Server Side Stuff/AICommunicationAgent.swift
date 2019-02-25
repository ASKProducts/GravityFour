//
//  AICommunicationAgent.swift
//  GravityFourTreeHacks
//
//  Created by Aaron Kaufer on 2/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class AICommunicationAgent {
    
    
    
    func getMove(for game: Game, difficulty: AIDifficulty, completion: @escaping (Move) -> ()){
        
        var moveHistoryString = ""
        for move in game.turnHistory {
            switch move {
            case let .drop(col):
                moveHistoryString += "\(col) "
            case let .rotate(dir):
                moveHistoryString += dir == .right ? "7 " : "8 "
            }
        }
        
        if moveHistoryString.count > 0{
            moveHistoryString.removeLast()
        }
        
        //SEND OFF moveHistoryString and get a response
        
        
        
        let diffNum = difficulty.rawValue
        let json: [String: Any] = ["mode": diffNum, "game": moveHistoryString]
        var jsonData: Data?
        do{
            jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        }catch{
            print("bigpoopy")
        }
        
        let url = URL(string: "https://us-central1-treehacks-1518852998483.cloudfunctions.net/ai")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData!
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                fatalError("big error")
                //return
            }
            
            guard let data = data else {
                fatalError("no data")
                //return
            }
            
            do {
                //create json object from data
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    fatalError("bad json")
                    //return
                }
                print(json)
                
                if json["ai"] == nil{
                    fatalError("ai not in json")
                }
                
                
                let responseInt = json["ai"]! as! Int
                
                if 0 <= responseInt && responseInt < 7 {
                    completion(.drop(responseInt))
                }
                else if responseInt == 7 {
                    completion(.rotate(.right))
                }
                else if responseInt == 8 {
                    completion(.rotate(.left))
                }
                else{
                    fatalError(" bad message recieved from server ")
                }
                
            } catch let error {
                print(error.localizedDescription)
                
                
                
            }
        })
        
        task.resume()
        

    }
    
}
