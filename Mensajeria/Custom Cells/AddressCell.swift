//
//  AddressCell.swift
//  Mensajeria
//
//  Created by Developer on 17/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateSavedLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        containerView.layer.shadowColor = UIColor.blackColor().CGColor
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowRadius = 1.0
        containerView.layer.shouldRasterize = true
        containerView.layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
