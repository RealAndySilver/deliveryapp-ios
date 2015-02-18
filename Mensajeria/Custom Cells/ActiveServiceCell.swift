//
//  ActiveServiceCell.swift
//  Mensajeria
//
//  Created by Developer on 13/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ActiveServiceCell: UITableViewCell {

    @IBOutlet weak var pickupAdressLabel: UILabel!
    @IBOutlet weak var deliveryAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
