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
        
        Api.app.getUser(login: self.login) {(user) in
            DispatchQueue.main.async {
                self.loginLabel.text = "\(user.login!) \(user.email!)"
                let image_url = URL(string: user.image_url!)
                self.profileImage.load(url: image_url!)
                self.user = user
                self.tableView.reloadData()
            }
        }
        
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
