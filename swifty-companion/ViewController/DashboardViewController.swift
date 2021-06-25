//
//  DashboardViewController.swift
//  swifty-companion
//
//  Created by Amine Mersoul on 6/25/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var login: String = "non";
    let myData = ["first", "second"]
    var user: User = User.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting label to empty
        self.loginLabel.text = ""
        self.levelLabel.text = ""
        self.pointLabel.text = ""
        self.campusLabel.text = ""
        self.emailLabel.text = ""
        
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        //loginLabel.adjustsFontSizeToFitWidth = false
        //loginLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        Api.app.getUser(login: self.login) {(user) in
            DispatchQueue.main.async {
                
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
                
                // setting data to UI
                self.loginLabel.text = user.login!
                self.levelLabel.text = String(format: "%.2f", user.cursus_users?.last?.level ?? "NAN")
                self.pointLabel.text = String(user.correction_point!)
                self.campusLabel.text = user.campus?[0].name!
                self.emailLabel.text = user.email!
                // loading profile image
                let image_url = URL(string: user.image_url!)
                self.profileImage.load(url: image_url!)
                // reloading table view
                self.user = user
                self.tableView.reloadData()
            }
        }
        
        let nib = UINib(nibName: "SkillsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SkillsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.cursus_users?.last?.skills?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SkillsTableViewCell", for: indexPath) as! SkillsTableViewCell
        cell.skillLabel?.text = user.cursus_users?.last?.skills?[indexPath.row].name
        cell.levelLabel.text = String(format: "%.2f", user.cursus_users?.last?.skills?[indexPath.row].level ?? "NAN")
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
