//
//  BuyViewCell.swift
//  Campus Buy
//
//  Created by siva lingam on 4/22/19.
//  Copyright © 2019 NIU. All rights reserved.
//

import UIKit

class BuyViewCell: UITableViewCell {
    
    
    @IBOutlet weak var buyImageView: UIImageView!
    @IBOutlet weak var buyNameLabel: UILabel!
    @IBOutlet weak var buyQtyLabel: UILabel!
    @IBOutlet weak var buyPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
