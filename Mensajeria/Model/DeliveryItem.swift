//
//  DeliveryItem.swift
//  Mensajeria
//
//  Created by Developer on 11/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit
class DeliveryItem: NSObject {
    
    var timeToPick: String
    var timeToDeliver: String
    var estimatedString: String?
    var estimatedDate: NSDate?
    var timeToMessengerArrival: Int? {
        get {
            if let theEstimatedDate = estimatedDate {
                var secondsToArrival = theEstimatedDate.timeIntervalSinceDate(NSDate())
                if secondsToArrival < 0 {
                    secondsToArrival = 0
                }
                let minutesToArrival = Int(secondsToArrival/60.0)
                return minutesToArrival
                
            } else {
                return nil
            }
        }
    }
    //var pickupStringTest: String
    var rated: Bool
    var name: String
    var status: String
    //var pickupTimeString: String
    var priority: Int
    var declaredValue: Int
    var identifier: String
    var deliveryObject: RequestObject
    var messengerInfo: MessengerInfo?
    var serviceImages = [ServiceImage]()
    var userInfo: UserInfo
    //var deadline: String
    var priceToPay: Int
    var userID: String
    var roundtrip: Bool
    var pickupObject: RequestObject
    var instructions: String
    var overallStatus: String
    var abortReason: String?
    var deliveryItemDescription: String {
        get {
            return "********** Info del delivery item *************\nname: \(name)\nstatus: \(status)\npriority: \(priority)\ndelivery object: \(deliveryObject.requestObjectDescription)\nuser info: \(userInfo.userInfoDescription)\npickup object: \(pickupObject.requestObjectDescription)\ndeclared value: \(declaredValue)\nmessenger info: \(messengerInfo?.messengerInfoDescription)"
        }
    }
    
    init(deliveryItemJSON: JSON) {
        //pickupStringTest = deliveryItemJSON["pickup_time"].stringValue
        
        timeToPick = deliveryItemJSON["time_to_pick"].stringValue
        timeToDeliver = deliveryItemJSON["time_to_deliver"].stringValue
        
        estimatedString = deliveryItemJSON["estimated"].string
        if let theEstimatedString = estimatedString {
            let range = Range(start: theEstimatedString.endIndex.advancedBy(-4), end: theEstimatedString.endIndex)
            estimatedString = theEstimatedString.stringByReplacingCharactersInRange(range, withString: "000Z")
            if let theEstimatedDate = AppInfo.sharedInstance.stringToDateFormatter.dateFromString(estimatedString!) {
                estimatedDate = theEstimatedDate
            }
        }
    
        
        /*let deliveryItemPickup = deliveryItemJSON["pickup_time"].stringValue
        if let pickupDate = AppInfo.sharedInstance.stringToDateFormatter.dateFromString(deliveryItemJSON["pickup_time"].stringValue) {
            pickupTimeString = AppInfo.sharedInstance.dateToStringFormatter.stringFromDate(pickupDate)
        } else {
            pickupTimeString = ""
        }
        
        if let deliveryDate = AppInfo.sharedInstance.stringToDateFormatter.dateFromString(deliveryItemJSON["deadline"].stringValue) {
            deadline = AppInfo.sharedInstance.dateToStringFormatter.stringFromDate(deliveryDate)
        } else {
            deadline = ""
        }*/
        
        name = deliveryItemJSON["item_name"].stringValue
        status = deliveryItemJSON["status"].stringValue
        priority = deliveryItemJSON["priority"].intValue
        declaredValue = deliveryItemJSON["declared_value"].intValue
        abortReason = deliveryItemJSON["abort_reason"].string
        deliveryObject = RequestObject(requestObjectJSON: JSON(deliveryItemJSON["delivery_object"].object))
        identifier = deliveryItemJSON["_id"].stringValue
        userInfo = UserInfo(userInfoJSON: JSON(deliveryItemJSON["user_info"].object))
        priceToPay = deliveryItemJSON["price_to_pay"].intValue
        userID = deliveryItemJSON["user_id"].stringValue
        roundtrip = deliveryItemJSON["roundtrip"].boolValue
        pickupObject = RequestObject(requestObjectJSON: JSON(deliveryItemJSON["pickup_object"].object))
        instructions = deliveryItemJSON["instructions"].stringValue
        overallStatus = deliveryItemJSON["overall_status"].stringValue
        messengerInfo = MessengerInfo(messengerInfoJSON: JSON(deliveryItemJSON["messenger_info"].object))
        rated = deliveryItemJSON["rated"].boolValue
        
        if let tempServiceImagesArray = deliveryItemJSON["images"].object as? [[String : AnyObject]] {
            for serviceImageDic in tempServiceImagesArray {
                let serviceImage = ServiceImage(serviceImageJSON: JSON(serviceImageDic))
                serviceImages.append(serviceImage)
            }
        }
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
    var profilePicString: String
    var time: String
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
        profilePicString = messengerInfoJSON["url"].stringValue
        time = messengerInfoJSON["time"].stringValue
        lastName = messengerInfoJSON["lastname"].stringValue
        plate = messengerInfoJSON["plate"].stringValue
        mobilePhone = messengerInfoJSON["mobilephone"].stringValue
        identifier = messengerInfoJSON["_id"].stringValue
        email = messengerInfoJSON["email"].stringValue
        identification = messengerInfoJSON["identification"].stringValue
        name = messengerInfoJSON["name"].stringValue
    }
    
    class func getMessengersObjectsFromArray(messengersArray: [[String: AnyObject]]) -> [MessengerInfo] {
        var messengers = [MessengerInfo]()
        for messengerDic in messengersArray {
            let messenger = MessengerInfo(messengerInfoJSON: JSON(messengerDic))
            messengers.append(messenger)
        }
        return messengers
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

class ServiceImage: NSObject {
    var identifier: String
    var deliveryStatus: String
    var urlString: String
    var ownerID: String
    var name: String
    var deliveryName: String
    var dateCreatedString: String
    
    init(serviceImageJSON: JSON) {
        identifier = serviceImageJSON["_id"].stringValue
        deliveryStatus = serviceImageJSON["delivery_status"].stringValue
        urlString = serviceImageJSON["url"].stringValue
        ownerID = serviceImageJSON["owner_id"].stringValue
        name = serviceImageJSON["name"].stringValue
        deliveryName = serviceImageJSON["delivery_name"].stringValue
        dateCreatedString = serviceImageJSON["date_created"].stringValue
    }
}
