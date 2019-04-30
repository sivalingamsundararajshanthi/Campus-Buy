//
//  CCViewController.swift
//  Campus Buy
//
//  Created by siva lingam on 4/25/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit

class CCViewController: UIViewController {
    
    weak var delegate : DataEnteredDelegate? = nil
    
    @IBOutlet weak var ccNumber: UITextField!
    @IBOutlet weak var ccSecurityCode: UITextField!
    @IBOutlet weak var ccName: UITextField!
    @IBOutlet weak var ccMonth: UITextField!
    @IBOutlet weak var ccYear: UITextField!
    
    
    @IBAction func useCreditCardButton(_ sender: UIButton) {
        
        //Check if any of the fields are empty
        if(ccNumber.text! == "" || ccSecurityCode.text! == "" || ccName.text! == "" || ccMonth.text == "" || ccYear.text! == ""){
            let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER ALL FIELDS", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        } else {
            //None of the fields are empty
            
            //Check if user has entered 16 values
            if(ccNumber.text?.count == 16){
                
                //Check if user has entered numbers
                if let convertedValue = Int64(ccNumber.text!){
                    print(convertedValue)
                    
                    //Check if user has entered name correctly
                    if let name = Int(ccName.text!){
                        print(name)
                        let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER NAME WITH LETTERS", preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                        
                        alert.addAction(cancelAction)
                        
                        self.present(alert, animated: true)
                    } else {
                        let name1 = ccName.text
                        print(name1 as Any)
                        
                        //Check if user has entered 3 digits for the security code
                        if(ccSecurityCode.text?.count == 3){
                            
                            //Check if user has entered numbers for the digit
                            if let convertedSec = Int(ccSecurityCode.text!){
                                print(convertedSec)
                                
                                //Check if user has entered a month
                                if let month = Int(ccMonth.text!){
                                    print(month)
                                    
                                    //Check if month is between 1 and 12
                                    if(month > 0 && month < 13){
                                        
                                        //Check if year is number and length is 4
                                        if let year = Int(ccYear.text!){
                                            if(ccYear.text?.count == 4){
                                                delegate?.userCreditCardDetails(number: convertedValue, securityCode: convertedSec, name: name1!, month: month, year: year)
                                                
                                                navigationController?.popViewController(animated: true)
                                            } else {
                                                let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER YEAR IN PROPER FORMAT", preferredStyle: .alert)
                                                
                                                let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                                                
                                                alert.addAction(cancelAction)
                                                
                                                self.present(alert, animated: true)
                                            }
                                        } else {
                                            let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER YEAR IN NUMBER", preferredStyle: .alert)
                                            
                                            let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                                            
                                            alert.addAction(cancelAction)
                                            
                                            self.present(alert, animated: true)
                                        }
                                    } else {
                                        let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER MONTH BETWEEN 1 and 12", preferredStyle: .alert)
                                        
                                        let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                                        
                                        alert.addAction(cancelAction)
                                        
                                        self.present(alert, animated: true)
                                    }
                                } else {
                                    
                                    let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER MONTH IN NUMBER", preferredStyle: .alert)
                                    
                                    let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                                    
                                    alert.addAction(cancelAction)
                                    
                                    self.present(alert, animated: true)
                                }
                            } else {
                                let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER ALL DIGITS FOR SECURITY CODE", preferredStyle: .alert)
                                
                                let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                                
                                alert.addAction(cancelAction)
                                
                                self.present(alert, animated: true)
                            }
                        } else {
                            let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER 3 DIGITS FOR SECURITY CODE", preferredStyle: .alert)
                            
                            let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                            
                            alert.addAction(cancelAction)
                            
                            self.present(alert, animated: true)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER DIGITS", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                    
                    alert.addAction(cancelAction)
                    
                    self.present(alert, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "ACTION REQUIRED", message: "PLEASE ENTER 16 DIGITS", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
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

protocol DataEnteredDelegate : class {
    func userCreditCardDetails(number: Int64, securityCode : Int, name : String, month : Int, year : Int)
}
