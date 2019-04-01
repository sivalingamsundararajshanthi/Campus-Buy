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
                        
                        User.customer = Customer(fName: self.fNameLabel.text!, lName: self.lNameLabel.text!, email: (user?.user.email)!, address: self.addressLabel.text!, phoneNumber: Int64(self.phoneLabel.text!)!, orderHistory : nil)

//                        User.customer = Customer(fName: "siva", lName: "lingam", email: "okay@gmail.com", address: "Chicago", phoneNumber: 8159098971, orderHistory : nil)

                        User.num = 1
                        
                        self.showWelcomeView()
                    }
                })
            } else {
                print("Please enter a valid email address")
            }
        }
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
        passwordLabel.delegate = self
        phoneLabel.delegate = self
        
        //Initialize the firebase reference
        ref = Database.database().reference()
    }
    
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
    
    /**
     This function is used to validate email entered by the user. If the email entered is not valid it returns false else true
     Source: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
     **/
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
