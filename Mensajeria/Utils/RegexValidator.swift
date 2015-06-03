//
//  RegexValidator.swift
//  Mensajeria
//
//  Created by Developer on 2/03/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class RegexValidator: NSObject {
    
    class func stringIsAValidEmail(emailString: String) -> Bool {
        let strictFilter = false
        let strictFilterString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let laxString = "[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+\\.[a-zA-Z]{2,4}"
        //let emailRegex = strictFilter ? strictFilterString : laxString
        let emailRegex = laxString
        let emailTest = NSPredicate(format: "SELF MATCHES '\(emailRegex)'")
        return emailTest.evaluateWithObject(emailString)
    }
}
