//
//  User.swift
//  Mensajeria
//
//  Created by Developer on 6/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

class User: NSObject {
    var identifier: String!
    var password: String!
    var emailConfirmation: Bool!
    var name: String!
    var email: String!
    var lastName: String!
    var mobilePhone: String!
    var favorites = []
    var device = []
    var userDescription: String {
        get {
            return "Name: \(name), Identifier: \(identifier), last name: \(lastName), email confirmation: \(emailConfirmation), email: \(email), mobilephone: \(mobilePhone)"
        }
    }
    var userDictionary: [String : AnyObject] {
        get {
            return ["name" : name, "email_confirmation" : emailConfirmation, "_id" : identifier, "email" : email, "lastname" : lastName, "mobilephone" : mobilePhone]
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
        //precondition(userJSON["mobilephone"].int != nil, "El mobile phone está en nill!!!")
        identifier = userJSON["_id"].stringValue
        name = userJSON["name"].stringValue
        email = userJSON["email"].stringValue
        lastName = userJSON["lastname"].stringValue
        emailConfirmation = userJSON["email_confirmation"].boolValue
        mobilePhone = userJSON["mobilephone"].stringValue
        //favorites = userJSON["favorites"].rawValue as []
        print(userDescription)
        
        //Save user info in NSUserDefaults 
        NSUserDefaults.standardUserDefaults().setObject(["name" : name, "_id" : identifier, "email" : email, "lastname" : lastName, "mobilephone" : mobilePhone], forKey: "UserInfo")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
