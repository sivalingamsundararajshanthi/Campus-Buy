//
//  CartViewController.swift
//  Campus Buy
//
//  Created by siva lingam on 3/31/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref : DatabaseReference?
    
    var items : [ItemDb]!
    
    var quantityTextField : UITextField?
    
    //Get an object of AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var cartTableView: UITableView!
    
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
    
    @IBAction func buyBtn(_ sender: Any) {
        let UID = Auth.auth().currentUser?.uid

        let ne = self.ref?.child("USERS/" + UID!).child("Past Orders").childByAutoId().child("ITEMS")

        var total = 0.0

        for item in items {
            total = total + item.price
            ne!.childByAutoId().setValue(["name" : item.name!, "price" : item.price, "quantity" : item.quantity])
        }
        
        
        self.ref?.child("USERS/" + UID!).child("Past Orders").observeSingleEvent(of: .value, with: { (DataSnapshot) in
            
            for snap in DataSnapshot.children {
                let userSnap = snap as! DataSnapshot
                
                let str = userSnap.key
                
                self.ref?.child("USERS/" + UID!).child("Past Orders").child(str).updateChildValues(["total" : total])
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //UIContextualAction for the swipe delete
        let remove = UIContextualAction(style: .normal, title: "Remove") { (UIContextualAction, view, nil) in
            
            //Delete the object from the CoreData
            self.context.delete(self.items[indexPath[1]])
            
            //Remove the object from the items array
            self.items.remove(at: indexPath[1])
            
            do{
                
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: items[indexPath[1]].name, message: "Edit Quantity", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: quantityTextField)
        quantityTextField?.text = String(items[indexPath[1]].quantity)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { (UIAlertAction) in
            
            //If entered value is not equal to quantity
            if(self.items[indexPath[1]].quantity != Int16((self.quantityTextField?.text)!)){
                
                //If entered value is greater than 0
                if(Int16((self.quantityTextField?.text)!)! > Int16(0)){
                    
                    //If entered value is greater than the DB value
                    if(Int16((self.quantityTextField?.text)!)! > self.items[indexPath[1]].quantity){
                        self.items[indexPath[1]].setValue(Int16((self.quantityTextField?.text)!), forKey: "quantity")
                        
                        var quantityInField = Int16((self.quantityTextField?.text)!) //Int16
                    
                        var quantityInDb = self.items[indexPath[1]].quantity //Int16
                        
                        var difference = quantityInField! - quantityInDb //Int16
                        
//                        var extraPrice = Double(difference) *
                        
                            self.items[indexPath[1]].setValue(Double((Int16((self.quantityTextField?.text)!)! - self.items[indexPath[1]].quantity)
                            * Int16(self.items[indexPath[1]].price)) + self.items[indexPath[1]].price, forKey: "price")
                        
//                        print(Int16((self.quantityTextField?.text)!)!)
//                        print(self.items[indexPath[1]].quantity)
//
//                        print((Int16((self.quantityTextField?.text)!)! - self.items[indexPath[1]].quantity)
//                            * Int16(self.items[indexPath[1]].price))
//
//                        print(Double((Int16((self.quantityTextField?.text)!)! - self.items[indexPath[1]].quantity)
//                            * Int16(self.items[indexPath[1]].price)) + self.items[indexPath[1]].price)
                        
                        do {
                            try self.context.save()
                            self.cartTableView.reloadData()
                        } catch {
                            print("error updating item \(error)")
                        }
                    }
                    
                    //If entered value is lesser than the DB value
                    else if(Int16((self.quantityTextField?.text)!)! < self.items[indexPath[1]].quantity){
                        
                    }
                }
            }
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
