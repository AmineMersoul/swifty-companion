//
//  DashboardViewController.swift
//  swifty-companion
//
//  Created by Amine Mersoul on 6/25/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var login: String = "non";
    let myData = ["first", "second"]
    var user: User = User.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginLabel.adjustsFontSizeToFitWidth = false
        loginLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        getUser(login: login)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.cursus_users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = user.cursus_users?[indexPath.row].cursus?.name
        return cell
    }
    
    struct Token: Decodable {
        let access_token: String?
        let token_type: String?
        let expires_in: Int?
        let scope: String?
        let created_at: Int?
        let error: String?
        let error_description: String?
    }
    
    func getToken() {
        let parameters:[String: Any] = ["grant_type": "client_credentials", "client_id": "e87fe820ff06559e6b6a561d2a6f37833f567f8ff54bdd3953dab3249cedc04d", "client_secret": "d7f5a08cb998a1faf965e67c8629e937b84c22da4b0196cf128987fdeb16ca87"]
        
        // token url
        let url = URL(string: "https://api.intra.42.fr/oauth/token")!
        
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
                print(token.access_token ?? "default value")
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        })
        task.resume()
    }
    
    func getUser(login: String) {
        
        // token url
        let url = URL(string: "https://api.intra.42.fr/v2/users/\(login)")!
        
        //create the session object
        let session = URLSession.shared

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        
        request.addValue("Bearer ebea4989a9a942b42009292d1686e3969d09d0eeebb10c38e624aa9d100ea37d", forHTTPHeaderField: "Authorization")
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
                // create json from data
                /*if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }*/
                // decoding from data
                self.user = try JSONDecoder().decode(User.self, from: data)
                print(self.user.email ?? "default value")
                DispatchQueue.main.async {
                    self.loginLabel.text = "\(self.user.login!) \(self.user.email!)"
                    let image_url = URL(string: self.user.image_url!)
                    self.profileImage.load(url: image_url!)
                    self.tableView.reloadData()
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        })
        task.resume()
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
