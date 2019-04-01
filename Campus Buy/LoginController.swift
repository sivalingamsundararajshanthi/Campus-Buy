//
//  LoginController.swift
//  Campus Buy
//
//  Created by siva lingam on 3/2/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore
import MBProgressHUD

class LoginController: UIViewController, UITextFieldDelegate {
    
    //outlets for email, password textfield and register label
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var huskieImageView: UIImageView!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    
    var emailTextField : UITextField?
    
    //This action will be performed when the login button is tapped
    @IBAction func loginButton(_ sender: UIButton) {
        
        //If either email or password is empty create an alert and inform user that all the details needs to be filled
        if(emailLabel.text == "" || passwordLabel.text == ""){
            let alert = UIAlertController(title: "🧐", message: "Please Enter all the details", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        //Else try signing in with the given user name and password
        else {
            Auth.auth().signIn(withEmail: emailLabel.text!, password: passwordLabel.text!, completion: {(user, error) in
                
                //No error sign in the user
                if(error == nil){
                    self.welcomeUser()
                }
                
                //Error in sign in tell the user that there is no such account with the given credentials
                else {
                    let alert = UIAlertController(title: "🤓", message: "USER NOT FOUND", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //MAke a tap gesture for the register label, set the number of taps to 1
        
        //Make email and password textfield delegate of itself
        emailLabel.delegate = self
        passwordLabel.delegate = self
        
        //Making the password hidden
        passwordLabel.isSecureTextEntry = true
        
        //Bring email in front of the picture
        emailLabel.bringSubviewToFront(huskieImageView)
        
        //The below lines are used to give the picture a fading effect in the bottom
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = huskieImageView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradient.locations = [0.0, 1]
        huskieImageView.layer.insertSublayer(gradient, at: 0)
        
        //Customizing the email textfield
        emailLabel.layer.cornerRadius = 8.0
        emailLabel.layer.masksToBounds = true
        emailLabel.layer.borderColor = UIColor.red.cgColor
        emailLabel.layer.borderWidth = 1.0
        
        //Customizing the password textfield
        passwordLabel.layer.cornerRadius = 8.0
        passwordLabel.layer.masksToBounds = true
        passwordLabel.layer.borderColor = UIColor.red.cgColor
        passwordLabel.layer.borderWidth = 1.0
        
        //Add a gesture recognizer for the register label.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(registerClick))
        tapGesture.numberOfTapsRequired = 1
        registerLabel.addGestureRecognizer(tapGesture)
        
        let tapGesture1 = UITapGestureRecognizer.init(target: self, action: #selector(forgotPassword))
        tapGesture1.numberOfTapsRequired = 1
        forgotPasswordLabel.addGestureRecognizer(tapGesture1)
        
        //Add notofications to know when the keyboard will show, will hide and will change frame
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //Add a tap gesture to dismiss the keyboard when the user taps anywhere on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func forgotPassword(){
        let alertController = UIAlertController(title: "Please Enter your email", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: emailTextField)
        
        let sendAction = UIAlertAction(title: "Send link", style: .default, handler: self.sendHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    func emailTextField(textField : UITextField){
        emailTextField = textField
    }
    
    func sendHandler(alert : UIAlertAction) {
        Auth.auth().sendPasswordReset(withEmail: (emailTextField?.text)!) { (error) in
            if error != nil {
                print("failure")
            }
        }
    }
    
    //Deinitializing the notifications for will show, will hide and will change frame
    deinit{
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //objective c function to hide the keyboard
    @objc func dismissKeyBoard(){
        view.endEditing(true)
    }
    
    //This is used to navigate to the next text field and dismiss the keyboard when the last textfield is reached
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    //This function is used to hide the keyboard
    func hideKeyBoard(){
        passwordLabel.resignFirstResponder()
    }
    
    //This is used to move the view to the top when the keyboard appears and also to bring back the view to the original place
    @objc func keyboardWillChange(notification: Notification){
        
        guard let keyBoardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyBoardRect.height + 50
        } else {
            view.frame.origin.y = 0
        }
    }
    
    //This objective function is used to navigate to the register controller
    @objc func registerClick(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "registercontroller") as! RegisterController
        self.present(newViewController, animated: true, completion: nil)
    }
    
    //This objective c function is used to navigate to the welcome controller upon successful login
    @objc func welcomeUser(){
        print("welcome user")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AFTERLOGINCONTROLLER") as! UINavigationController
        self.present(newViewController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
