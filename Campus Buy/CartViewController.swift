//
//  CartViewController.swift
//  Campus Buy
//
//  Created by siva lingam on 3/31/19.
//  Copyright © 2019 NIU. All rights reserved.
//
/*
 Purpose: This is the cart view controller. Here items can be removed by sliding left. From this screen orders cal also be placed.
 */

import UIKit
import CoreData
import Firebase

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Reference to the firebase database
    var ref : DatabaseReference?
    
    //Array of items in the order
    var items : [ItemDb]!
    
    var quantityTextField : UITextField?
    
    //Get an object of AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Table view for cart items
    @IBOutlet weak var cartTableView: UITableView!
    
    //This is used to close the cart view controller
    @IBAction func doneBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        
    }
    
    @IBAction func qntValueChanged(_ sender: UITextField) {
        let cell: UITableViewCell = sender.superview?.superview as! UITableViewCell
        let table: UITableView = cell.superview as! UITableView
        let textFieldIndexPath = table.indexPath(for: cell)
        
        print(textFieldIndexPath!)
    }
    
    //This is the IBAction for the Buy Button
    @IBAction func buyBtn(_ sender: Any) {
        
        //Get the current user's UID
        let UID = Auth.auth().currentUser?.uid

        //Create a child subtree called as PAST ORDERS if not present else update
        let ne = self.ref?.child("USERS/" + UID!).child("Past Orders").childByAutoId().child("ITEMS")

        //Variable to store the total
        var total = 0.0

        //Fetch each item in items array and upload it to firebase using autoid
        for item in items {
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
    
    //Return the number of items in the row
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Return the number of items in the items array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    //This is used to populate the cell in the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item:ItemDb = items[indexPath.row]
        
        let cell = cartTableView.dequeueReusableCell(withIdentifier: "CARTCELL") as! CartViewCell
        
        let cellImageName = item.url
        
        let url = URL(string: cellImageName!)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            
            DispatchQueue.main.async {
                cell.cartImage.image = UIImage(data: data!)
            }
        }
        
        cell.cartName.text = item.name
        cell.cartQnt.text = String(item.quantity)
        cell.cartPrice.text = "$" + String(item.price)
        
        return cell
    }
    
    //This is used to delete the item from the table view
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //UIContextualAction for the swipe delete
        let remove = UIContextualAction(style: .normal, title: "Remove") { (UIContextualAction, view, nil) in
            
            //Get the item from the items array
            let item : ItemDb = self.items[indexPath[1]]
            
            do{
                
                //Fetch request to fetch corresponding item from QuantityDb
                let fetchRequest = NSFetchRequest<QuantityDb>(entityName: "QuantityDb")
                
                //Fetch request predicate to fetch the item whose name matches
                fetchRequest.predicate = NSPredicate(format: "name = %@", item.name!)
                
                //try and fetch
                let test = try self.context.fetch(fetchRequest)
                
                //If count is 1
                if(test.count == 1){
                    //If name matches
                    if(test[0].name == item.name){
                
                        //Fetch the first item from the returned array
                        let objectUpdate = test[0]
                        
                        //Sum the quantities
                        let currentQuantity = item.quantity + test[0].quantity
                        
                        //Update the quantity
                        objectUpdate.setValue(currentQuantity, forKey: "quantity")
                        
                        //Delete the object from the CoreData
                        self.context.delete(self.items[indexPath[1]])
                        
                        //Remove the object from the items array
                        self.items.remove(at: indexPath[1])
                    }
                }
                
                //Save the context
                try self.context.save()
                
                //Delete the row
                self.cartTableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                
                //Error in deleting the object
                print("error deleting item \(error)")
            }
        }
        
        //Assigning the color red to the UIContextualAction
        remove.backgroundColor = UIColor.red
        
        return UISwipeActionsConfiguration(actions: [remove])
    }
    
    /*
     This function is used to edit the quantity of an item in the table view
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Alert controller for the edit quantity
        let alertController = UIAlertController(title: items[indexPath[1]].name, message: "Edit Quantity", preferredStyle: .alert)
        
        //Add a text field to the alert controller
        alertController.addTextField(configurationHandler: quantityTextField)
        quantityTextField?.text = String(items[indexPath[1]].quantity)
        
        //This is used to update the quantity of the item in the core data
        let updateAction = UIAlertAction(title: "Update", style: .default) { (UIAlertAction) in
            
            //Check if quantity in the core data and text field is not equal and the value entered is greater than zero
            if((self.items[indexPath[1]].quantity != Int16((self.quantityTextField?.text)!))
                && (Int16((self.quantityTextField?.text)!)! > Int16(0))){
                
                //Get enetered quantity from the text field
                let quantityField = Int16((self.quantityTextField?.text)!)
                
                //Calculate the price for the quantity entered
                let newPrice = Double(quantityField!) * self.items[indexPath[1]].originalPrice
                
                //Update the quantity in the core data
                self.items[indexPath[1]].setValue(quantityField, forKey: "quantity")
                
                //Update the price
                self.items[indexPath[1]].setValue(newPrice, forKey: "price")
                
                do {
                    try self.context.save()
                    self.cartTableView.reloadData()
                } catch {
                    print("error updating item \(error)")
                }
            }
            
            //If entered value is not equal to quantity
//            if(self.items[indexPath[1]].quantity != Int16((self.quantityTextField?.text)!)){
//
//                //If entered value is greater than 0
//                if(Int16((self.quantityTextField?.text)!)! > Int16(0)){
//
//                    //If entered value is greater than the DB value
////                    if(Int16((self.quantityTextField?.text)!)! > self.items[indexPath[1]].quantity){
////
////                        let quantityInField = Int16((self.quantityTextField?.text)!) //Int16
////
////                        let quantityInDb = self.items[indexPath[1]].quantity //Int16
////
////                        let difference = quantityInField! - quantityInDb //Int16
////
////                        let extraPrice = Double(difference) * self.items[indexPath[1]].originalPrice
////
////                        let newPrice = extraPrice + self.items[indexPath[1]].price
////
//////                        print(quantityInField)
//////                        print(quantityInDb)
//////                        print(difference)
//////                        print(extraPrice)
////
////                        self.items[indexPath[1]].setValue(Int16((self.quantityTextField?.text)!), forKey: "quantity")
////
////                        self.items[indexPath[1]].setValue(newPrice, forKey: "price")
////
////                        do {
////                            try self.context.save()
////                            self.cartTableView.reloadData()
////                        } catch {
////                            print("error updating item \(error)")
////                        }
////                    }
//
//                    //If entered value is lesser than the DB value
////                    else if(Int16((self.quantityTextField?.text)!)! < self.items[indexPath[1]].quantity){
////                        let quantityInField = Int16((self.quantityTextField?.text)!) //Int16
////
////                        let quantityInDb = self.items[indexPath[1]].quantity //Int16
////
////                        let difference = quantityInDb - quantityInField! //Int16
////
////                        let newPrice = Double(difference) * self.items[indexPath[1]].originalPrice
////
////                        self.items[indexPath[1]].setValue(Int16((self.quantityTextField?.text)!), forKey: "quantity")
////
////                        self.items[indexPath[1]].setValue(newPrice, forKey: "price")
////
////                        do {
////                            try self.context.save()
////                            self.cartTableView.reloadData()
////                        } catch {
////                            print("error updating item \(error)")
////                        }
////                    }
//                }
//            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    func quantityTextField(textField : UITextField){
        quantityTextField = textField
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartTableView.rowHeight = 150

        // Do any additional setup after loading the view.
        loadFromDb()
        
        ref = Database.database().reference()
    }
    
    func loadFromDb(){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request : NSFetchRequest<ItemDb> = ItemDb.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        do{
            try items = context.fetch(request)
        } catch {
            print("Error fetching \(error)")
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
