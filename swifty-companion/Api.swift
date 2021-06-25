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
        
        let defaults = UserDefaults.standard
        
        let access_token = defaults.string(forKey: "access_token")
        
        if (access_token != nil) {
            print("retrive token from local storage: \(access_token ?? "")")
            completion(Token(access_token: access_token, token_type: "", expires_in: 0, scope: "", created_at: 0, error: "", error_description: ""))
            return
        }
        
        let parameters:[String: Any] = ["grant_type": "client_credentials", "client_id": clientId, "client_secret": clientSecret]
        
        // token url
        let url = URL(string: tokenUrl)!
        
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
                defaults.set(token.access_token, forKey: "access_token")
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
            let url = URL(string: self.userUrl + login)!
            
            //create the session object
            let session = URLSession.shared

            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            
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
