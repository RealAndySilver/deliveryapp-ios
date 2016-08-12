//
//  UIImage+CreditCard.swift
//  Mensajeria
//
//  Created by Diego Vidal on 18/03/16.
//  Copyright © 2016 iAm Studio. All rights reserved.
//

import Foundation

enum CreditCardIdentifier: String {
    case Visa = "VISA"
    case MasterCard = "MASTERCARD"
    case Amex = "AMEX"
    case Dinners = "DINERS"
    //case VisaElectron = "VE"
}

extension UIImage {
  
    convenience init!(creditCardIdentifier: CreditCardIdentifier) {
        switch creditCardIdentifier {
        case .Visa:
            self.init(named: "CardVisa")
        case .MasterCard:
            self.init(named: "CardMastercard")
        case .Amex:
            self.init(named: "CardAmericanExpress")
        case .Dinners:
            self.init(named: "CardDinners")
        //case .VisaElectron:
            //self.init(named: "CardVisaElectron")
        }
    }
    
}