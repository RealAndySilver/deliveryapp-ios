//
//  DeliveryItem.swift
//  Mensajeria
//
//  Created by Developer on 11/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit
//item_name
class DeliveryItem: NSObject {
    
    var name: String
    var status: String
    var pickupTimeString: String
    var priority: Int
    var declaredValue: Int
    var identifier: String
    var deliveryObject: RequestObject
    var messengerInfo: MessengerInfo?
    var userInfo: UserInfo
    var deadline: String
    var priceToPay: Int
    var userID: String
    var roundtrip: Bool
    var pickupObject: RequestObject
    var instructions: String
    var overallStatus: String
    var deliveryItemDescription: String {
        get {
            return "********** Info del delivery item *************\nname: \(name)\nstatus: \(status)\npickup time: \(pickupTimeString)\npriority: \(priority)\ndelivery object: \(deliveryObject.requestObjectDescription)\nuser info: \(userInfo.userInfoDescription)\npickup object: \(pickupObject.requestObjectDescription)\ndeclared value: \(declaredValue)\nmessenger info: \(messengerInfo?.messengerInfoDescription)"
        }
    }
    
    init(deliveryItemJSON: JSON) {
        /*let stringToDateFormatter = NSDateFormatter()
        stringToDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        stringToDateFormatter.locale = NSLocale.currentLocale()
        
        let dateToStringFormatter = NSDateFormatter()
        dateToStringFormatter.dateStyle = .LongStyle
        dateToStringFormatter.timeStyle = .ShortStyle
        dateToStringFormatter.locale = NSLocale.currentLocale()*/
        
        if let pickupDate = AppInfo.sharedInstance.stringToDateFormatter.dateFromString(deliveryItemJSON["pickup_time"].stringValue) {
            pickupTimeString = AppInfo.sharedInstance.dateToStringFormatter.stringFromDate(pickupDate)
        } else {
            pickupTimeString = ""
        }
        
        if let deliveryDate = AppInfo.sharedInstance.stringToDateFormatter.dateFromString(deliveryItemJSON["deadline"].stringValue) {
            deadline = AppInfo.sharedInstance.dateToStringFormatter.stringFromDate(deliveryDate)
        } else {
            deadline = ""
        }
        
        name = deliveryItemJSON["item_name"].stringValue
        status = deliveryItemJSON["status"].stringValue
        //pickupTimeString = deliveryItemJSON["pickup_time"].stringValue
        priority = deliveryItemJSON["priority"].intValue
        declaredValue = deliveryItemJSON["declared_value"].intValue
        
        deliveryObject = RequestObject(requestObjectJSON: JSON(deliveryItemJSON["delivery_object"].object))
        identifier = deliveryItemJSON["_id"].stringValue
        //deadline = deliveryItemJSON["deadline"].stringValue
        userInfo = UserInfo(userInfoJSON: JSON(deliveryItemJSON["user_info"].object))
        priceToPay = deliveryItemJSON["price_to_pay"].intValue
        userID = deliveryItemJSON["user_id"].stringValue
        roundtrip = deliveryItemJSON["roundtrip"].boolValue
        pickupObject = RequestObject(requestObjectJSON: JSON(deliveryItemJSON["pickup_object"].object))
        instructions = deliveryItemJSON["instructions"].stringValue
        overallStatus = deliveryItemJSON["overall_status"].stringValue
        messengerInfo = MessengerInfo(messengerInfoJSON: JSON(deliveryItemJSON["messenger_info"].object))
    }
}

class RequestObject: NSObject {
    var latitude: String
    var longitude: String
    var address: String
    var requestObjectDescription: String {
        get {
            return "latitude: \(latitude) ---- longitude: \(longitude) ---- address: \(address)"
        }
    }
    init(requestObjectJSON: JSON) {
        latitude = requestObjectJSON["lat"].stringValue
        longitude = requestObjectJSON["lon"].stringValue
        address = requestObjectJSON["address"].stringValue
    }
}

class MessengerInfo: NSObject {
    var lastName: String
    var plate: String
    var mobilePhone: String
    var identifier: String
    var email: String
    var identification: String
    var name: String
    var messengerInfoDescription: String {
        get {
            return "name: \(name) --- lastname: \(lastName) --- plate: \(plate)\nmobilephone: \(mobilePhone) --- identifier: \(identifier) --- email: \(email)\nidentification: \(identification)"
        }
    }
    init (messengerInfoJSON: JSON) {
        lastName = messengerInfoJSON["lastname"].stringValue
        plate = messengerInfoJSON["plate"].stringValue
        mobilePhone = messengerInfoJSON["mobilephone"].stringValue
        identifier = messengerInfoJSON["_id"].stringValue
        email = messengerInfoJSON["email"].stringValue
        identification = messengerInfoJSON["identification"].stringValue
        name = messengerInfoJSON["name"].stringValue
    }
}

class UserInfo: NSObject {
    var name: String
    var identifier: String
    var lastName: String
    var email: String
    var userInfoDescription: String {
        get {
            return "name: \(name) --- identifier: \(identifier) --- lastname: \(lastName) --- email: \(email)"
        }
    }
    init(userInfoJSON: JSON) {
        name = userInfoJSON["name"].stringValue
        identifier = userInfoJSON["_id"].stringValue
        lastName = userInfoJSON["lastname"].stringValue
        email = userInfoJSON["email"].stringValue
    }
}
