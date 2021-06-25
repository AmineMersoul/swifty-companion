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
    @IBOutlet weak var projectTableView: UITableView!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var projectsLabel: UILabel!
    
    var login: String = "non";
    let myData = ["first", "second"]
    var user: User = User.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting label to empty
        loginLabel.text = ""
        levelLabel.text = ""
        pointLabel.text = ""
        campusLabel.text = ""
        emailLabel.text = ""
        skillsLabel.text = ""
        projectsLabel.text = ""
        
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
                
                if (user.login?.isEmpty ?? true) {
                    // create the alert
                    let alert = UIAlertController(title: "Login Wrong", message: "Please enter a valid login.", preferredStyle: UIAlertController.Style.alert)
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "Got it", style: UIAlertAction.Style.default, handler: nil))
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
                
                // setting data to UI
                self.loginLabel.text = user.login ?? ""
                self.levelLabel.text = String(format: "%.2f", user.cursus_users?.last?.level ?? "NAN")
                self.pointLabel.text = String(user.correction_point ?? 0)
                self.campusLabel.text = user.campus?[0].name ?? ""
                self.emailLabel.text = user.email ?? ""
                self.skillsLabel.text = "Skills:"
                self.projectsLabel.text = "Projects:"
                
                // loading profile image
                let image_url = URL(string: user.image_url ?? "https://via.placeholder.com/300")
                self.profileImage.load(url: image_url!)
                // reloading table view
                self.user = user
                self.tableView.reloadData()
                self.projectTableView.reloadData()
            }
        }
        
        let skillNib = UINib(nibName: "SkillsTableViewCell", bundle: nil)
        tableView.register(skillNib, forCellReuseIdentifier: "SkillsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        let projectNib = UINib(nibName: "ProjectTableViewCell", bundle: nil)
        projectTableView.register(projectNib, forCellReuseIdentifier: "ProjectTableViewCell")
        projectTableView.delegate = self
        projectTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tableView){
            return user.cursus_users?.last?.skills?.count ?? 0
        }
        return user.projects_users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if(tableView == self.tableView){
            let skillCell = tableView.dequeueReusableCell(withIdentifier: "SkillsTableViewCell", for: indexPath) as! SkillsTableViewCell
            skillCell.skillLabel?.text = user.cursus_users?.last?.skills?[indexPath.row].name
            skillCell.levelLabel.text = String(format: "%.2f", user.cursus_users?.last?.skills?[indexPath.row].level ?? "NAN")
            return skillCell
        }
        let projectCell = tableView.dequeueReusableCell(withIdentifier: "ProjectTableViewCell", for: indexPath) as! ProjectTableViewCell
        projectCell.projectLabel?.text = user.projects_users?[indexPath.row].project?.name
        projectCell.markLabel.text = String(user.projects_users?[indexPath.row].final_mark ?? 0)
        let finalMark: Int = user.projects_users?[indexPath.row].final_mark ?? 0
        if (finalMark < 100) {
            projectCell.validatedImageView.image = UIImage(systemName: "xmark");
            projectCell.validatedImageView.tintColor = UIColor.red
        } else {
            projectCell.validatedImageView.image = UIImage(systemName: "checkmark");
            projectCell.validatedImageView.tintColor = UIColor.green
        }
        return projectCell
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
