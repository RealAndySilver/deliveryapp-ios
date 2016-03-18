//
//  CreditCard.swift
//  Mensajeria
//
//  Created by Diego Vidal on 18/03/16.
//  Copyright © 2016 iAm Studio. All rights reserved.
//

import Foundation

class CreditCard {
    let lastFourNumbers: String
    let franchise: String
    let token: String
    init(lastFourNumbers: String, franchise: String, token: String) {
        self.lastFourNumbers = lastFourNumbers
        self.franchise = franchise
        self.token = token
    }
    
    init(creditCardJson: JSON) {
        self.franchise = creditCardJson["franchise"].stringValue
        self.lastFourNumbers = creditCardJson["card_last4"].stringValue
        self.token = creditCardJson["token"].stringValue
    }
}