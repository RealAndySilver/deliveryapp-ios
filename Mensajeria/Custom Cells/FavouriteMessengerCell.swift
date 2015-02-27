//
//  FavouriteMessengerCell.swift
//  Mensajeria
//
//  Created by Developer on 25/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class FavouriteMessengerCell: UITableViewCell {

    @IBOutlet weak var messengerPlate: UILabel!
    @IBOutlet weak var messengerImageView: UIImageView!
    @IBOutlet weak var messengerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
