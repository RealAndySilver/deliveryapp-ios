//
//  Formatters.swift
//  Mensajeria
//
//  Created by Developer on 24/11/15.
//  Copyright © 2015 iAm Studio. All rights reserved.
//

import Foundation

class Formatters {
    static let sharedInstance = Formatters()
    private init() {}
    
    let stringToDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd\'T\'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    let dateToStringFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
}