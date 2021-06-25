//
//  SearchViewController.swift
//  swifty-companion
//
//  Created by Amine Mersoul on 6/25/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tf_login: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func searchButton(_ sender: Any) {
        let login:String = tf_login.text ?? ""
        if (login.isEmpty) {
            // create the alert
            let alert = UIAlertController(title: "Login Required", message: "Please enter a login.", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "Got it", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            print("get user with login: \(login)")
            performSegue(withIdentifier: "showDashboard", sender: login)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDashboard" {
            let dashboardVC = segue.destination as! DashboardViewController
            let login = sender as! String
            dashboardVC.login = login
        }
    }
    
}

