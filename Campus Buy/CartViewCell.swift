//
//  CartViewCell.swift
//  Campus Buy
//
//  Created by siva lingam on 3/31/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit

class CartViewCell: UITableViewCell {
    
    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var cartName: UILabel!
    @IBOutlet weak var cartQnt: UILabel!
    @IBOutlet weak var cartPrice: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
