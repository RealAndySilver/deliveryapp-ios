//
//  AppInfo.swift
//  Mensajeria
//
//  Created by Developer on 18/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class AppInfo {
    
    //Singleton
    /*static var sharedInstance: AppInfo {
        struct Static {
            static let instance: AppInfo = AppInfo()
        }
        return Static.instance
    }*/
    static let sharedInstance = AppInfo()
    
    private init() { }
    
    var insurancesValues: [Int]?
    
    var deliveryItemStatusList = ["available", "accepted", "in-transit", "returning", "returned", "delivered"]
    lazy var stringToDateFormatter: NSDateFormatter = {
        print("entre a nicializarrr")
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = NSLocale.currentLocale()
        return formatter
        }()
    lazy var dateToStringFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle
        formatter.locale = NSLocale.currentLocale()
        return formatter
    }()
    
    
}
