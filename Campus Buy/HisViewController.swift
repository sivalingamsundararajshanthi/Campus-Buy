//
//  HisViewController.swift
//  Campus Buy
//
//  Created by siva lingam on 4/29/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit
import Firebase

class HisViewController: UIViewController {
    
    struct order : Decodable {
        
    }
    
    var ref : DatabaseReference?
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ref = Database.database().reference()
        
        getFromFB()
    }
    
    func getFromFB(){
        let UID = Auth.auth().currentUser?.uid
        
        let userDb = Database.database().reference().child("USERS/" + UID! + "/Past Orders")
        
        userDb.observeSingleEvent(of: .value) { (DataSnapshot) in
            if DataSnapshot.exists(){
                userDb.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    for snap in DataSnapshot.children{
                        
                    }
                })
            } else {
                
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
