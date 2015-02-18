//
//  AddressCell.swift
//  Mensajeria
//
//  Created by Developer on 17/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {

    @IBOutlet weak var dateSavedLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
