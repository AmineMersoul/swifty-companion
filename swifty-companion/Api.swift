//
//  Api.swift
//  swifty-companion
//
//  Created by Amine Mersoul on 6/25/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import Foundation

class Api {
    
    let tokenUrl: String = "https://api.intra.42.fr/oauth/token"
    let clientId: String = "e87fe820ff06559e6b6a561d2a6f37833f567f8ff54bdd3953dab3249cedc04d"
    let clientSecret: String = "d7f5a08cb998a1faf965e67c8629e937b84c22da4b0196cf128987fdeb16ca87"
    let userUrl: String = "https://api.intra.42.fr/v2/users/"
    
    static let app: Api = {
        return Api()
    }()
    
    func getToken(completion: @escaping (Token) -> ()) {
        
        // geting token from device
        let defaults = UserDefaults.standard
        let access_token = defaults.string(forKey: "access_token")
        let created_at = defaults.integer(forKey: "created_at")
        
        // check if token exist in device
        if (access_token != nil && created_at != 0) {
            print("retrive token from device: \(access_token ?? "") created at: \(created_at)")
            
            let token = Token(access_token: access_token, token_type: "", expires_in: 0, scope: "", created_at: created_at, error: "", error_description: "")
            
            // check if valid token
            let timestamp = Int(NSDate().timeIntervalSince1970)
            if (timestamp < (token.created_at! + 7200)) {
                print("token is still valid")
                completion(token)
                return
            } else {
                print("token has expired!")
            }
        } else {
            print("token not found")
        }
        
        print("getting new token");
        
        let parameters:[String: Any] = ["grant_type": "client_credentials", "client_id": self.clientId, "client_secret": self.clientSecret]
        
        // token url
        let url = URL(string: self.tokenUrl)!
        
        //create the session object
        let session = URLSession.shared

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                // decoding from data
                let token = try JSONDecoder().decode(Token.self, from: data)
                print("token: \(token.access_token ?? "token")")
                print("created_at: \(token.created_at ?? 0)")
                defaults.set(token.access_token, forKey: "access_token")
                defaults.set(token.created_at, forKey: "created_at")
                completion(token)
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func getUser(login: String, completion: @escaping (User) -> ()) {
        
        getToken() {(token) in
            // token url
            let url = URL(string: self.userUrl + login)
            
            //create the session object
            let session = URLSession.shared

            //now create the URLRequest object using the url object
            var request = URLRequest(url: url ?? URL(string: self.userUrl)!)
            
            request.addValue("Bearer \(token.access_token!)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    if (user.error?.isEmpty ?? true) {
                        print("we got the user email: \(user.email ?? "email")")
                        completion(user)
                    } else {
                        print("need new token")
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                
            })
            task.resume()
        }
    }
    
}
