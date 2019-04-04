//
//  WelcomeViewController.swift
//  Campus Buy
//
//  Created by siva lingam on 3/11/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var images : [String] = ["Clothing.jpg", "Electronics.jpg", "stationaries.jpg"]
    var names : [String] = ["Clothing", "Electronics", "Stationaries"]
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! CollectionViewCell
        
        cell.cellImageView.image = UIImage(named: images[indexPath.row])
        cell.cellTextView.text = names[indexPath.row]
        
        return cell
    }
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            directToLoginPage()
        } catch{}
    }
    
    @objc func directToLoginPage(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "LOGINCONTROLLER") as! LoginController
        
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "INVENTORYSEGUE"){
            let inventoryVC = segue.destination as? InventoryViewController
            
            let index = self.categoryCollectionView.indexPathsForSelectedItems
            
            if(index![0][1] == 0){
                inventoryVC?.category = "CLOTHING"
            } else if(index![0][1] == 1){
                inventoryVC?.category = "ELECTRONICS"
            } else {
                inventoryVC?.category = "STATIONARY"
            }
        }
    }
}
