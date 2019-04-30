//
//  BuyViewController.swift
//  Campus Buy
//
//  Created by siva lingam on 4/22/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit
import Firebase

class BuyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DataEnteredDelegate {
    
    struct ccDetail : Decodable{
        let num : Int64?
        let sec : Int?
        let name : String?
        let month : Int?
        let year : Int?
    }
    
    var creditCard : ccDetail?
    
    /*
     This function is used to get the credit card details from the credit card screen
     */
    func userCreditCardDetails(number: Int64, securityCode: Int, name: String, month: Int, year: Int) {
        
        creditCard = ccDetail(num: number, sec: securityCode, name: name, month: month, year: year)
        
        self.creditCardButton.setTitle("Pay with: " + String(describing: creditCard!.num!) + " or Add new", for: .normal)
        
        /*
        //If the particular variable is not nil, create and intialize
        if(creditCardFromNext == nil){
            creditCardFromNext = CreditCard(number: number, securityCode: securityCode, month: month, year: year)
            
            //Set the details in the button
            self.creditCardButton.setTitle("Pay with: " + String(describing: (self.creditCardFromNext?.number)!) + " or Add new", for: .normal)
        }*/
    }
    
    //Array of ItemDb
    var items = [ItemDb]()
    
    //Variable to recieve the credit card details from the cc view
    var creditCardFromNext : CreditCard!
    
    //Variable to recieve the credit card details from the Firebase
    var creditCardNew : CreditCard!
    
    //Firebase database reference
    var ref : DatabaseReference?
    
    var ccTextField : UITextField?
    var secTextField : UITextField?
    var monthTextField : UITextField?
    var yearTextField : UITextField?
    
    var crediCardNumber : String?
    var secCode : String?
    var month : String?
    var year : String?
    
    var check : Bool = false
    
    //Add credit card button
    @IBOutlet weak var creditCardButton: UIButton!
    
    
    @IBAction func creditCardButtonAction(_ sender: UIButton) {
        
    }
    
    @IBOutlet weak var totalLabel: UILabel!
    
    //Needs work
    @IBAction func buyButton(_ sender: UIButton) {
        
        let UID = Auth.auth().currentUser?.uid
        
        let userDb = Database.database().reference().child("USERS/" + UID! + "/CreditCard")
        
        userDb.observeSingleEvent(of: .value) { (DataSnapshot) in
            
            //If credit card exists
            if DataSnapshot.exists(){
                print("Success")
                
                //Create a child subtree called as PAST ORDERS if not present else update
                let ne = self.ref?.child("USERS/" + UID!).child("Past Orders").childByAutoId().child("ITEMS")
                
                //Variable to store the total
                var total = 0.0
                
                //Fetch each item in items array and upload it to firebase using autoid
                for item in self.items {
                    //Increment the price
                    total = total + item.price
                    ne!.childByAutoId().setValue(["name" : item.name!, "price" : item.price, "quantity" : item.quantity])
                    
                    self.ref?.child("PRODUCTS/" + item.category!.uppercased()).child(item.name!).child("quantity").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                        if let quantity = DataSnapshot.value as? Int {
                            print("quantity")
                            print(quantity)
                            if(quantity != 0){
                                let updatedQuantity = Int16(quantity) - item.quantity
                                self.ref?.child("PRODUCTS/" + item.category!.uppercased()).child(item.name!).updateChildValues(["quantity": updatedQuantity])
                            }
                        }
                    })
                }
                
                //The following is used to set the total and date
                self.ref?.child("USERS/" + UID!).child("Past Orders").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    
                    for snap in DataSnapshot.children {
                        let userSnap = snap as! DataSnapshot
                        
                        let str = userSnap.key
                        
                        //Set the total
                        self.ref?.child("USERS/" + UID!).child("Past Orders").child(str).updateChildValues(["total" : total])
                        
                        //Get the current date details
                        let currentDate = Date().description(with: .current)
                        
                        //Set the date
                        self.ref?.child("USERS/" + UID!).child("Past Orders").child(str).updateChildValues(["date" : currentDate])
                    }
                })
            }
            
            //If credit card doesnt exist
            else {
                
                //We got details from the ccViewController
                if (self.creditCard != nil){
                    //Place the order
                    //Create a child subtree called as PAST ORDERS if not present else update
                    let ne = self.ref?.child("USERS/" + UID!).child("Past Orders").childByAutoId().child("ITEMS")
                    
                    //Variable to store the total
                    var total = 0.0
                    
                    //Fetch each item in items array and upload it to firebase using autoid
                    for item in self.items {
                        //Increment the price
                        total = total + item.price
                        ne!.childByAutoId().setValue(["name" : item.name!, "price" : item.price, "quantity" : item.quantity])
                        
                        self.ref?.child("PRODUCTS/" + item.category!.uppercased()).child(item.name!).child("quantity").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                            if let quantity = DataSnapshot.value as? Int {
                                print("quantity")
                                print(quantity)
                                if(quantity != 0){
                                    let updatedQuantity = Int16(quantity) - item.quantity
                                    self.ref?.child("PRODUCTS/" + item.category!.uppercased()).child(item.name!).updateChildValues(["quantity": updatedQuantity])
                                }
                            }
                        })
                    }
                    
                    //The following is used to set the total and date
                    self.ref?.child("USERS/" + UID!).child("Past Orders").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                        
                        for snap in DataSnapshot.children {
                            let userSnap = snap as! DataSnapshot
                            
                            let str = userSnap.key
                            
                            //Set the total
                            self.ref?.child("USERS/" + UID!).child("Past Orders").child(str).updateChildValues(["total" : total])
                            
                            //Get the current date details
                            let currentDate = Date().description(with: .current)
                            
                            //Set the date
                            self.ref?.child("USERS/" + UID!).child("Past Orders").child(str).updateChildValues(["date" : currentDate])
                        }
                    })
                }
                
                //We did not get the credit card details
                else {
                    //Show alert
                    let alertController = UIAlertController(title: "CREDIT CARD", message: "PLEASE ENTER CREDIT CARD DETAILS", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OKAY", style: .cancel, handler: nil)
                    
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    func ccTextField(textField : UITextField){
        ccTextField = textField
        ccTextField?.placeholder = "Enter 16 digits"
    }
    
    func secTextField(textField : UITextField){
        secTextField = textField
        secTextField?.placeholder = "Enter Security Code"
    }
    
    func monthTextField(textField : UITextField){
        monthTextField = textField
        monthTextField?.placeholder = "Enter Month"
    }
    
    func yearTextField(textField : UITextField){
        yearTextField = textField
        yearTextField?.placeholder = "Enter Year"
    }
    
    //Table view to display the items
    @IBOutlet weak var buyTableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item:ItemDb = items[indexPath.row]
        
        let cell = buyTableView.dequeueReusableCell(withIdentifier: "BUYCELL") as! BuyViewCell
        
        let cellImageName = item.url
        
        let url = URL(string: cellImageName!)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            
            DispatchQueue.main.async {
                cell.buyImageView.image = UIImage(data: data!)
            }
        }
        
        cell.buyNameLabel.text = item.name
        cell.buyPriceLabel.text = "$" + String(item.price)
        cell.buyQtyLabel.text = String(item.quantity)
        
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Initialize the Firebase Database variable
        ref = Database.database().reference()
        
        //Set the row height
        self.buyTableView.rowHeight = 150
        
        //Calculate the total price
        var totalPrice = 0.0
        for i in items{
            totalPrice = totalPrice + i.price
        }
        
        //Set the total price
        totalLabel.text = "$" + String(totalPrice)
        
        
        checkForCC()
    }
    
    /*
     This function is used to check whether credit card details exist in the Firebase
     */
    func checkForCC(){
        
        //Get user UID for the current user
        let UID = Auth.auth().currentUser?.uid
        
        //Get reference of credit card node
        let userDb = Database.database().reference().child("USERS/" + UID! + "/Credit Card")
        
        //Observe the Credit card node
        userDb.observeSingleEvent(of: .value) { (DataSnapshot) in
            
            //If it exists set new value in button
            if DataSnapshot.exists(){
                self.creditCardButton.setTitle("Success", for: .normal)
                
                if let dictionary = DataSnapshot.value as? [String : AnyObject]{
                    let number = dictionary["number"]
                    let securityCode = dictionary["security code"]
                    let month = dictionary["month"]
                    let year = dictionary["year"]
                    
                    self.creditCardNew = CreditCard(number: number as! Int64, securityCode: securityCode as! Int, month: month as! Int, year: year as! Int)
                    
                    self.creditCardButton.setTitle("Pay with: " + String(describing: (self.creditCardNew?.number)!) + " or Add new", for: .normal)
                }
            }
            
            //Else set default text
            else {
                self.creditCardButton.setTitle("Add Credit Card", for: .normal)
            }
        }
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        
        if segue.identifier == "CCNAV" {
            
            //Set to nil so that we can recieve new data
            creditCardFromNext = nil
            
            let destVC = segue.destination as! CCViewController
            
            destVC.delegate = self
        }
     }
     
    
}
