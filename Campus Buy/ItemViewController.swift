//
//  ItemViewController.swift
//  Campus Buy
//
//  Created by siva lingam on 3/25/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //Array of strings to display in the picker view
    var number : [String] = [String]()
    
    //Item object that gets passed from the ItemViewController
    var item : InventoryItem!
    
    //This variable is used to store the number of quantities picked by the user
    var numberOfItem : Int!
    
    //Number of coulmns for the picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Number of items in the column
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return number.count
    }
    
    //This is used to display the picker view
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return number[row]
    }
    
    //Action to do when the user selects a quantity
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        //Store quantity in numberOfItem
        numberOfItem = Int(number[row])
    }
    
    //Outlets for image, name, price
    @IBOutlet weak var inventoryImage: UIImageView!
    @IBOutlet weak var inventoryName: UILabel!
    @IBOutlet weak var inventoryPrice: UILabel!
    
    //Outlet for the quantity picker view
    @IBOutlet weak var quantPicker: UIPickerView!
    
    //Action to perform when the user selects the add to cart button.
    //Write Core Data logic here
    @IBAction func cartButton(_ sender: Any) {
        
        //Calculate the price of the items added
        if(numberOfItem == nil){
            numberOfItem = 1
        }
        
        let totalPrice = self.item.price * Double(numberOfItem)
        
        //Get Appdelegate object
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //Request for fetching ItemDb objects from DB
        let request : NSFetchRequest<ItemDb> = ItemDb.fetchRequest()
        
        //Predicate for the query
        let predicate = NSPredicate(format: "name MATCHES %@", item.name)
        
        //Assigning the predicate to the request
        request.predicate = predicate
        
        //Array to store the return values
        var itemArray : [ItemDb]?
        
        
        do {
            //Try to fetch the values
            itemArray = try context.fetch(request)
        } catch {
            //Error in getting items
            print("error fetching data \(error)")
        }
        
        //If the itemArray is empty
        if(itemArray?.count == 0){
            
            //Create a new dbItem
            let dbItem = ItemDb(context: context)
            
            //Set up properties
            dbItem.name = self.item.name
            dbItem.quantity = Int16(numberOfItem)
            dbItem.price = totalPrice
            dbItem.url = item.picURL
            
            
            do{
                //Save the object on to Core Data
                try context.save()
                print("Success")
            } catch {
                print("Error adding item to cart \(error)")
            }
        }
        
        //If the itemArray is not empty
        else {
            
            //Set the new quantity
            itemArray![0].setValue(itemArray![0].quantity + Int16(numberOfItem), forKey: "quantity")
            
            //Set the new price
            itemArray![0].setValue(itemArray![0].price + (Double(numberOfItem) * item.price), forKey: "price")
            
            do {
                //try to update the values
                try context.save()
            } catch {
                //Failed to update
                print("Fail to update")
            }
        }
    }
    
    @IBAction func seeCartButton(_ sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "CARTCONTROLLERVIEW") as! UINavigationController
        self.present(controller, animated: false, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Delegatig quantity picker to item view controller
        
        self.navigationItem.title = item.name
        
        self.quantPicker.delegate = self
        self.quantPicker.dataSource = self
        
        //Check if item is not nil
        if(item != nil){
            
            //Setting the text, price
            inventoryName.text = item.name
            inventoryPrice.text = "$" + String(item.price)
            
            //Getting the url from the item object
            let url = URL(string: item.picURL)
            
            //Fetch the image in the background thread
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                
                //Update the picture in the UI
                DispatchQueue.main.async {
                    self.inventoryImage.image = UIImage(data: data!)
                }
            }
            
            //Set the number of values -> quantity picker
            for i in 0..<item.quantity{
                number.append(String(i+1))
            }
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
