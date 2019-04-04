//
//  RegisterController.swift
//  Campus Buy
//
//  Created by siva lingam on 3/2/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RegisterController: UIViewController, UITextFieldDelegate {
    
    //Firebase database reference
    var ref : DatabaseReference?
    
    //Outlets for first name, last name, email, address, phone, password
    @IBOutlet weak var fNameLabel: UITextField!
    @IBOutlet weak var lNameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    
    
    @IBOutlet weak var addressLabel: UITextField!
    
    
    @IBOutlet weak var phoneLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    //IBAction which needs to be executed when the register button is clicked
    @IBAction func registerButton(_ sender: UIButton) {
        
        //User has some field that is empty
        if(fNameLabel.text == "" || lNameLabel.text == "" || emailLabel.text == "" || addressLabel.text == "" || phoneLabel.text == "" ||
            passwordLabel.text == ""){
        }

        //User has entered all the fields
        else {
            //Check if entered email is valid
            if(isValidEmail(testStr: emailLabel.text!)){
                //If entered email is in correct format try to create the user profile in the firebase
                Auth.auth().createUser(withEmail: emailLabel.text!, password: passwordLabel.text!, completion: {(user, error) in
                    if(error == nil){
                        self.ref?.child("USERS").child((user?.user.uid)!)
                            .setValue(["fName" : self.fNameLabel.text,"lName" : self.lNameLabel.text,"email" : user?.user.email,
                                       "address" : self.addressLabel.text, "phoneNumber" : self.phoneLabel.text])
                        
                        self.showWelcomeView()
                    }
                })
            } else {
                print("Please enter a valid email address")
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showWelcomeView(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "AFTERLOGINCONTROLLER") as! UINavigationController
        self.present(controller, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fNameLabel.delegate = self
        lNameLabel.delegate = self
        emailLabel.delegate = self
        passwordLabel.delegate = self
        addressLabel.delegate = self
        phoneLabel.delegate = self
        
        //Making the password text field as secure
        passwordLabel.isSecureTextEntry = true
        
        //Initialize the firebase reference
        ref = Database.database().reference()
        
        //Add notofications to know when the keyboard will show, will hide and will change frame
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //Add a tap gesture to dismiss the keyboard when the user taps anywhere on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        view.addGestureRecognizer(tap)
    }
    
    //Deinitializing the notifications for will show, will hide and will change frame
    deinit{
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //objective c function to hide the keyboard
    @objc func dismissKeyBoard(){
        print("dismisskeyboard")
        view.endEditing(true)
    }
    
    //This is used to navigate to the next text field and dismiss the keyboard when the last textfield is reached
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            print(textField.tag)
            nextField.becomeFirstResponder()
            if(nextField.tag == 4){
                nextField.returnKeyType = .done
            }
        } else {
            // Not found, so remove keyboard.
            print("else")
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    //This function is used to hide the keyboard
    func hideKeyBoard(){
        print("hidekey board")
        passwordLabel.resignFirstResponder()
    }
    
    /**
     This function is used to validate email entered by the user. If the email entered is not valid it returns false else true
     Source: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
     **/
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

/*func registerForKeyboardNotifications(){
    //Adding notifies on keyboard appearing
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)
}

func deregisterFromKeyboardNotifications(){
    //Removing notifies on keyboard appearing
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)
}

@objc func keyboardWasShown(notification: NSNotification){
    //Need to calculate keyboard exact size due to Apple suggestions
    self.scrollView.isScrollEnabled = true
    var info = notification.userInfo!
    let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
    let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
    
    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
    
    var aRect : CGRect = self.view.frame
    aRect.size.height -= keyboardSize!.height
    if let activeField = self.activeField {
        if (!aRect.contains(activeField.frame.origin)){
            self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }
}

@objc func keyboardWillBeHidden(notification: NSNotification){
    //Once keyboard disappears, restore original positions
    var info = notification.userInfo!
    let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
    let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
    self.view.endEditing(true)
    self.scrollView.isScrollEnabled = false
}

func textFieldDidBeginEditing(_ textField: UITextField){
    activeField = textField
}

func textFieldDidEndEditing(_ textField: UITextField){
    activeField = nil
}
*/
