//
//  DeliveryItem.swift
//  Mensajeria
//
//  Created by Developer on 11/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class DeliveryItem: NSObject {
    var status: String
    var pickupTimeString: String
    var priority: Int
    var declaredValue: Int
    var identifier: String
    var deliveryObject: RequestObject
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
            return "********** Info del delivery item *************\nstatus: \(status)\npickup time: \(pickupTimeString)\npriority: \(priority)\ndelivery object: \(deliveryObject.requestObjectDescription)\nuser info: \(userInfo.userInfoDescription)\npickup object: \(pickupObject.requestObjectDescription)\ndeclared value: \(declaredValue)"
        }
    }
    
    init(deliveryItemJSON: JSON) {
        status = deliveryItemJSON["status"].stringValue
        pickupTimeString = deliveryItemJSON["pickup_time"].stringValue
        priority = deliveryItemJSON["priority"].intValue
        declaredValue = deliveryItemJSON["declared_value"].intValue
        
        deliveryObject = RequestObject(requestObjectJSON: JSON(deliveryItemJSON["delivery_object"].object))
        identifier = deliveryItemJSON["_id"].stringValue
        deadline = deliveryItemJSON["deadline"].stringValue
        userInfo = UserInfo(userInfoJSON: JSON(deliveryItemJSON["user_info"].object))
        priceToPay = deliveryItemJSON["price_to_pay"].intValue
        userID = deliveryItemJSON["user_id"].stringValue
        roundtrip = deliveryItemJSON["roundtrip"].boolValue
        pickupObject = RequestObject(requestObjectJSON: JSON(deliveryItemJSON["pickup_object"].object))
        instructions = deliveryItemJSON["instructions"].stringValue
        overallStatus = deliveryItemJSON["overall_status"].stringValue
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
