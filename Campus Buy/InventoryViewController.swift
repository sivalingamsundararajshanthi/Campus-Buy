//
//  InventoryViewController.swift
//  Campus Buy
//
//  Created by siva lingam on 3/19/19.
//  Copyright © 2019 NIU. All rights reserved.
/*Purpose : The purpose of this view controller is to fetch and show the details of clothing, electronics, stationaries. Additionally when the app
    first loads up it fetches the quantity from the Firebase to CoreData.
 */

import UIKit
import FirebaseDatabase

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Fetch object of AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Outlet for the collection view
    @IBOutlet weak var inventoryCol: UICollectionView!
    
    //This function is used to return the number of items in the items array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //This function is used to populate the collection view with data
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Fetch the object from the array
        let item : InventoryItem = items[indexPath.row]
        
        //Get a reference of the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "INVENTORYCELL", for: indexPath) as! InventoryCollectionViewCell
        
        //Convert url string to url
        let url = URL(string: item.picURL)
        
        //Fetch the image in the background thread
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            
            //Display the image in the main thread
            DispatchQueue.main.async {
                cell.inventoryImage.image = UIImage(data: data!)
            }
        }
        
        //Set the name
        cell.inventoryName.text = item.name
        
        //return the cell
        return cell
    }
    
    //Array of InventoryItem objects
    var items = [InventoryItem]()
    
    //Firebase database reference
    var ref : DatabaseReference?
    
    //This is the category string
    var category : String!
    
    @IBAction func cartButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "CARTCONTROLLERVIEW") as! UINavigationController
        self.present(controller, animated: false, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //Set the titile of view controller
        self.navigationItem.title = category
        
        //Get a reference of the Firebase database
        ref = Database.database().reference()
        
        //Make collection view display 2 views in a row
        configureCollectionViewLayout()
        
        //Fetch the data from the firebase
        fetchData(clothing: category)
    }
    
    /*
     This function is used to make the collection view to display two cells in a row
     */
    func configureCollectionViewLayout() {
        // take have of the screen size, minus 5 points
        let itemSize = UIScreen.main.bounds.width/2 - 5
        
        // create our custom layout for our collection view
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        // set spacing between items in the collection view
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        // attach our layout to the collectionView
        inventoryCol.collectionViewLayout = layout
    }

    /*
     This function is used to fetch the data from the firebase
     */
    func fetchData(clothing:String){
        
        //Get a reference of the described sub tree
        ref?.child("PRODUCTS/" + clothing).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            //If children count is greater than 0
            if snapshot.childrenCount > 0 {
                
                //This variable is to check if we reached the end of the data inside the children tree
                var i = 0
                
                //for loop to go through all the child nodes
                for inventory in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    //Increment the count each time
                    i = i + 1
                    
                    //Fetching each node as dictionary
                    let inventoryObject = inventory.value as? [String : AnyObject]
                    
                    //Fetch name, url, category object, price and quantity from the dictionary
                    let name = inventoryObject?["name"]
                    let url = inventoryObject?["picURL"]
                    let categoryObject = inventoryObject?["category"]
                    let category = Category(name: categoryObject?["name"] as! String, id: categoryObject?["id"] as! Int)
                    let price = inventoryObject?["price"]
                    let quantity = inventoryObject?["quantity"]
                    
                    //If passed in string is CLOTHING
                    if(clothing == "CLOTHING"){
                        
                        //If clo bool from testForDownload is equal to false
                        if(!testForDownload.clo){
                            
                            //If we reached the end of the data i.e. the last item then set to true
                            if(i == snapshot.children.allObjects.count){
                            //Make it to true
                                testForDownload.clo = true
                            }
                            
                            //Get an instance of QuantityDb
                            let quantityDb = QuantityDb(context: self.context)
                            
                            //Set category, name and quantity
                            quantityDb.category = category.name
                            quantityDb.name = name as? String
                            quantityDb.quantity = (quantity as? Int16)!
                            
                            do{
                                //Save the object in the db
                                try self.context.save()
                            } catch{
                                
                                //Error in saving the object
                                print("Error adding item to db \(error)")
                            }
                        }
                    }
                    
                    //If passed in quantity is ELECTRONICS
                    else if(clothing == "ELECTRONICS") {
    
                        //If elec bool from testForDownload is equal to false
                        if(!testForDownload.elec){
                            
                            if(i == snapshot.children.allObjects.count){
                                //Make it to true
                                testForDownload.elec = true
                            }
                            
                            //Get an instance of QuantityDb
                            let quantityDb = QuantityDb(context: self.context)
                            
                            //Set category, name and quantity
                            quantityDb.category = category.name
                            quantityDb.name = name as? String
                            quantityDb.quantity = (quantity as? Int16)!
                            
                            do{
                                //Save the object in the db
                                try self.context.save()
                            } catch{
                                //Error in saving the object
                                print("Error adding item to db\(error)")
                            }
                        }
                    }
                    
                    //If passed in quantity is STATIONARY
                    else {
                        
                        //If sta bool from testForDownload is equal to false
                        if(!testForDownload.sta){
                            
                            if(i == snapshot.children.allObjects.count){
                                //Make it to true
                                testForDownload.sta = true
                            }
                            
                            //Get an instance of QuantityDb
                            let quantityDb = QuantityDb(context: self.context)
                            
                            //Set category, name and quantity
                            quantityDb.category = category.name
                            quantityDb.name = name as? String
                            quantityDb.quantity = (quantity as? Int16)!
                            
                            do{
                                //Save the object in the db
                                try self.context.save()
                            } catch{
                                //Error in saving the object
                                print("Error adding item to db\(error)")
                            }
                        }
                    }
                    
                    //Apeend InventoryItem objects into items
                    self.items.append(InventoryItem(name: name as! String, category: category, quantity: quantity as! Int, price: price as! Double, picURL: url as! String))
                    
                    //Reload the collection view
                    DispatchQueue.main.async {
                        self.inventoryCol.reloadData()
                    }
                }
            }
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "ITEMCOLLECTION"){
            let indexPath = inventoryCol.indexPathsForSelectedItems?.first
            
            let destVC = segue.destination as! ItemViewController
            destVC.item = items[indexPath![1]]
        }
    }
    

}
