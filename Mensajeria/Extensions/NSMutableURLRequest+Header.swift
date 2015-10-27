//
//  NSMutableURLRequest+Header.swift
//  vrum
//
//  Created by Developer on 27/04/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    class func createURLRequestWithHeaders(urlString: String, methodType: String, theParameters: [String: AnyObject]? = nil) -> NSMutableURLRequest? {
        print("URL STRING ***********: \(urlString)")
        let encodedString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        if let url = NSURL(string: encodedString) {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = methodType
            
            let encodedPassword = User.sharedInstance.password.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions([])
            let authField = "\(User.sharedInstance.email):\(encodedPassword)"
            let encodedAuthField = authField.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions([])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("user", forHTTPHeaderField: "type")
            request.setValue("Basic \(encodedAuthField)", forHTTPHeaderField: "Authorization")
            
            if let theParameters = theParameters {
                request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(theParameters, options: NSJSONWritingOptions())
            }
            return request
        
        } else {
            return nil
        }
    }
}