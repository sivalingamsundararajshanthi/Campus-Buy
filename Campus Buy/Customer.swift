//
//  Customer.swift
//  Campus Buy
//
//  Created by siva lingam on 3/3/19.
//  Copyright © 2019 NIU. All rights reserved.
//

/**
 This class is used to create the customer object.
 (1)fname - First Name.
 (2)lName - Last Name.
 (3)email - email address
 (4)address - Physical address
 (5)phone number - Phone number of the customer
 (6)orderHistory - An array of Order Objects which shows history of orders made by the customer.
 **/
import Foundation

class Customer : NSObject {
    
    //Object fields
    var userId : String!
    var fName : String!
    var lName : String!
    var email : String!
    var address : String!
    var phoneNumber : Int64!
    var orderHistory : [Order]?
    
    //Constructor for the Customer class
    init(fName:String, lName:String, email:String, address:String, phoneNumber:Int64, orderHistory : [Order]?){
        self.fName = fName
        self.lName = lName
        self.email = email
        self.address = address
        self.phoneNumber = phoneNumber
        self.orderHistory = orderHistory
    }
}
