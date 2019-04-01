//
//  Category.swift
//  Campus Buy
//
//  Created by siva lingam on 3/3/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import Foundation

class Category : NSObject {
    
    var name : String!
    var id : Int!
    
    init(name:String, id:Int) {
        self.name = name
        self.id = id
    }
}
