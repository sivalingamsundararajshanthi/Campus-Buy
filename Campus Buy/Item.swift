//
//  Item.swift
//  Campus Buy
//
//  Created by siva lingam on 3/25/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import Foundation

class Item : NSObject {
    
    var item : InventoryItem!
    var quantity : Int!
    var price : Double!
    
    init(item:InventoryItem, quantity:Int, price:Double){
        self.item = item
        self.quantity = quantity
        self.price = price
    }
}
