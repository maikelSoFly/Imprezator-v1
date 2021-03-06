//
//  SecondViewController.swift
//  Guests
//
//  Created by Mikołaj Stępniewski on 04.07.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit
import Firebase

class SecondViewController: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var accountInfoLabel: UILabel!
    
    @IBAction func actionLogOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            guests.removeAll()
            didLoggedOut = true
            checkedCounter = 0
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        accountInfoLabel.text = "You are not logged"
        logOutButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logOutButton.layer.borderWidth = 0.5
        logOutButton.layer.borderColor = UIColor.lightGray.cgColor
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let email = Auth.auth().currentUser?.email {
            accountInfoLabel.text = "You are logged as \(email)"
            logOutButton.isEnabled = true
        } else {
            accountInfoLabel.text = "You are not logged"
            logOutButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

