//
//  RegexValidator.swift
//  Mensajeria
//
//  Created by Developer on 2/03/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class RegexValidator: NSObject {
    
    class func stringIsAValidEmail(emailString: String?) -> Bool {
        //let laxString = "[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+\\.[a-zA-Z]{2,4}"
        let laxString = "[A-Za-z0-9._%+]+@[A-Za-z0-9]+\\.[A-Za-z]{1,5}"
        let emailRegex = laxString
        let emailTest = NSPredicate(format: "SELF MATCHES '\(emailRegex)'")
        return emailTest.evaluateWithObject(emailString)
    }
    
    class func stringIsAValidName(textToValidate: String?) -> Bool {
        let laxString = "[a-zA-Z ]+"
        let emailTest = NSPredicate(format: "SELF MATCHES '\(laxString)'")
        return emailTest.evaluateWithObject(textToValidate)
    }
    
    class func stringIsAValidCC(textToValidate: String?) -> Bool {
        let laxString = "[1-9]\\d{4,9}"
        let emailTest = NSPredicate(format: "SELF MATCHES '\(laxString)'")
        return emailTest.evaluateWithObject(textToValidate)
    }
    
    class func stringIsAValidNIT(textToValidate: String?) -> Bool {
        let laxString = "[1-9]\\d{6,8}\\-?\\d?"
        let emailTest = NSPredicate(format: "SELF MATCHES '\(laxString)'")
        return emailTest.evaluateWithObject(textToValidate)
    }
    
    class func stringIsAValidCE(textToValidate: String?) -> Bool {
        let laxString = "[a-zA-Z]*[1-9]\\d{3,7}"
        let emailTest = NSPredicate(format: "SELF MATCHES '\(laxString)'")
        return emailTest.evaluateWithObject(textToValidate)
    }
    
    class func stringIsAValidTI(textToValidate: String?) -> Bool {
        let laxString = "\\d{2}[0-1][0-9][0-3][0-9]\\-\\d{5}"
        let emailTest = NSPredicate(format: "SELF MATCHES '\(laxString)'")
        return emailTest.evaluateWithObject(textToValidate)
    }
    
    class func stringIsAValidPPN(textToValidate: String?) -> Bool {
        let laxString = "\\w{4,12}"
        let emailTest = NSPredicate(format: "SELF MATCHES '\(laxString)'")
        return emailTest.evaluateWithObject(textToValidate)
    }
}
