//
//  CreditCard.swift
//  Mensajeria
//
//  Created by Diego Vidal on 18/03/16.
//  Copyright © 2016 iAm Studio. All rights reserved.
//

import Foundation

class CreditCard {
    let identifier: String
    let lastFourNumbers: String
    let franchise: String
    //let token: String
    init(lastFourNumbers: String, franchise: String, identifier: String) {
        self.lastFourNumbers = lastFourNumbers
        self.franchise = franchise
        //self.token = token
        self.identifier = identifier
    }
    
    init(creditCardJson: JSON) {
        self.franchise = creditCardJson["franchise"].stringValue
        self.lastFourNumbers = creditCardJson["card_last4"].stringValue
        //self.token = creditCardJson["token"].stringValue
        self.identifier = creditCardJson["_id"].string!
    }
}