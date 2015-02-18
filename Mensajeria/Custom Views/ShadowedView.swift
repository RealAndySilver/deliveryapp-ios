//
//  ShadowedView.swift
//  Mensajeria
//
//  Created by Developer on 18/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ShadowedView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 1.0
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }
}
