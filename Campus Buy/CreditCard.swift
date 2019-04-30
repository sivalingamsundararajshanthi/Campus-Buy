//
//  CreditCard.swift
//  Campus Buy
//
//  Created by siva lingam on 4/25/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import Foundation

class CreditCard : NSObject {
    var number : Int64
    var securityCode : Int
    var month : Int
    var year : Int
    
    init(number : Int64, securityCode : Int, month : Int, year : Int){
        self.number = number
        self.securityCode = securityCode
        self.month = month
        self.year = year
    }
}
