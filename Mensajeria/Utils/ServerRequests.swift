//
//  ServerRequests.swift
//  Mensajeria
//
//  Created by Developer on 14/12/15.
//  Copyright © 2015 iAm Studio. All rights reserved.
//

import Foundation

class ServerRequests {
    
    static func getInsurancesValues(completion: Result<AnyObject, NSError> -> Void) {
        WrapperAlamofire.sharedManager.request(.GET, url: Alamofire.getInsurancesValues, parameterEncoding: .JSON) { (resultObject) -> Void in
            completion(resultObject)
        }
    }
}