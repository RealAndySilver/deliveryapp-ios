//
//  ShadowedButton.swift
//  Mensajeria
//
//  Created by Developer on 19/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ShadowedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 0.0
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }
}
