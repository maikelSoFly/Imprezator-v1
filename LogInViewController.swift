//
//  LogInViewController.swift
//  Guests
//
//  Created by Mikołaj Stępniewski on 06.07.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit
import Firebase

protocol LogInDelegate {
    func pullData()
}

class LogInViewController: UIViewController {
    
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textBoxesContainer: UIView!
    
    var delegate:LogInDelegate?
    var loginSuccess = false
    
    @IBAction func actionButtonClose(_ sender: Any) {
        delegate?.pullData()
        navigationController?.dismiss(animated: true, completion: nil)
     
        //dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logInSegue" {
            let sourceView = segue.source as! GuestTableViewController
            sourceView.test = "halko"
        }
    }
    

    @IBAction func actionButton(_ sender: UIButton) {
        self.delegate?.pullData()
        activityIndicator.startAnimating()
        let email = emailTextField?.text
        let password = passwordTextField?.text
        if email != nil && password != nil {
            Auth.auth().signIn(withEmail: email!, password: password!, completion: { (user, error) in
                if error != nil {
                    print(error!)
                    let strErr = String(describing: error!)
                    if strErr.contains("ERROR_INVALID_EMAIL") {
                        self.errorMsgLabel.text = "Invalid e-mail address"
                    }
                    else if strErr.contains("ERROR_WRONG_PASSWORD") {
                        self.errorMsgLabel.text = "Invalid password"
                    }
                    
                    self.activityIndicator.stopAnimating()
                    return
                }
                
               
                self.activityIndicator.stopAnimating()
                
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.isEnabled = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        
        errorMsgLabel.text = ""
        
        button.layer.cornerRadius = 25
        
        textBoxesContainer.layer.cornerRadius = 5
        
        nameTextField.layer.cornerRadius = 5
        nameTextField.placeholder = "User name"
        
        emailTextField.layer.cornerRadius = 5
        emailTextField.placeholder = "Email address"
        
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.placeholder = "Password"
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.nameTextField.frame.height))
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.emailTextField.frame.height))
        let paddingView3 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.passwordTextField.frame.height))
        
        
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = UITextFieldViewMode.always
        
        emailTextField.leftView = paddingView2
        emailTextField.leftViewMode = UITextFieldViewMode.always
        
        passwordTextField.leftView = paddingView3
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        
        passwordTextField.isSecureTextEntry = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
