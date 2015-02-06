//
//  User.swift
//  Mensajeria
//
//  Created by Developer on 6/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

class User: NSObject {
    var identifier: String!
    var emailConfirmation: Bool!
    var name: String!
    var email: String!
    var lastName: String!
    var userDescription: String {
        get {
            return "Name: \(name), Identifier: \(identifier), last name: \(lastName), email confirmation: \(emailConfirmation), email: \(email)"
        }
    }
    
    class var sharedInstance: User {
        struct Static {
            static let instance: User = User()
        }
        return Static.instance
    }
    
    func updateUserWithJSON(userJSON: JSON) {
        precondition(userJSON["name"].string != nil, "Username is nil!!!")
        precondition(userJSON["_id"].string != nil, "user id is nil!!!")
        precondition(userJSON["email"].string != nil, "user email is nil")
        precondition(userJSON["lastname"].string != nil, "User lastname is nil!!!")
        identifier = userJSON["identifier"].stringValue
        name = userJSON["name"].stringValue
        email = userJSON["email"].stringValue
        lastName = userJSON["lastname"].stringValue
        emailConfirmation = userJSON["email_confirmation"].boolValue
        println(userDescription)
    }
}
