//
//  InventoryItem.swift
//  Campus Buy
//
//  Created by siva lingam on 3/3/19.
//  Copyright © 2019 NIU. All rights reserved.
//

/**
 This class is used to create the inventory items.
 (1)name - The name of the item
 (2)category - The category to which the item belongs to
 (3)quantity - The number of items in the inventory
 (4)price - The price of the item
 (5)picURL - The URL from which the item  picture can be fethced
 **/
import Foundation

class InventoryItem : NSObject {
    
    //Object fields
    var name : String!
    var category : Category!
    var quantity : Int!
    var price : Double!
    var picURL : String!
    
    //Constructor for InventoryItem class
    init(name:String, category:Category, quantity:Int, price:Double, picURL:String) {
        self.name = name
        self.category = category
        self.quantity = quantity
        self.price = price
        self.picURL = picURL
    }
}
