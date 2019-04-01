//
//  InventoryViewController.swift
//  Campus Buy
//
//  Created by siva lingam on 3/19/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit
import FirebaseDatabase

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var inventoryCol: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(items.count)
        return items.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item : InventoryItem = items[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "INVENTORYCELL", for: indexPath) as! InventoryCollectionViewCell
        
        let url = URL(string: item.picURL)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            
            DispatchQueue.main.async {
                cell.inventoryImage.image = UIImage(data: data!)
            }
        }
        
        cell.inventoryName.text = item.name
        
        return cell
    }
    
    
    var items = [InventoryItem]()
    var ref : DatabaseReference?
    var category : String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = category
        ref = Database.database().reference()
        
        configureCollectionViewLayout()
        
        fetchData(clothing: category)
        
    }
    
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

    func fetchData(clothing:String){
        
        ref?.child("PRODUCTS/" + clothing).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for inventory in snapshot.children.allObjects as! [DataSnapshot] {
                    let inventoryObject = inventory.value as? [String : AnyObject]
                    
                    let name = inventoryObject?["name"]
                    let url = inventoryObject?["picURL"]
                    let categoryObject = inventoryObject?["category"]
                    let category = Category(name: categoryObject?["name"] as! String, id: categoryObject?["id"] as! Int)
                    let price = inventoryObject?["price"]
                    let quantity = inventoryObject?["quantity"]
                    
                    self.items.append(InventoryItem(name: name as! String, category: category, quantity: quantity as! Int, price: price as! Double, picURL: url as! String))
                    
                    DispatchQueue.main.async {
                        self.inventoryCol.reloadData()
                    }
                }
            }
        })
        
        //self.inventoryCol.reloadData()
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
