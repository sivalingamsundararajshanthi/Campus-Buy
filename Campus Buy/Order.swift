//
//  Order.swift
//  Campus Buy
//
//  Created by siva lingam on 3/3/19.
//  Copyright © 2019 NIU. All rights reserved.
//

/**
 This class is used to represent the Order.
 (1)customer - The Customer who placed the order.
 (2)items - The list of Inventory items that were purchased
 (3)price - The price of the order
 **/
import Foundation

class Order : NSObject {
    
    //Object fields
//    var customer : Customer!
    var items : [Item]!
    var total : Double!
    
    //Constructor for the Order class
    init(items:[Item], total:Double){
        self.items = items
        self.total = total
    }
}
