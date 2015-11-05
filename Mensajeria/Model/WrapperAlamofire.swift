//
//  HTTPRequestsController.swift
//  Mensajeria
//
//  Created by Developer on 27/10/15.
//  Copyright © 2015 iAm Studio. All rights reserved.
//

import Foundation

enum WrapperAlamofireHTTPMethod: String {
    case GET
    case POST
    case PUT
}

enum WrapperAlamofireParameterEncoding {
    case URL
    case JSON
}

class WrapperAlamofire {
    
    static let sharedManager = WrapperAlamofire()
    
    func request(httpMethod: WrapperAlamofireHTTPMethod, url: URLStringConvertible, parameterEncoding: WrapperAlamofireParameterEncoding, parameters: [String : AnyObject]? = .None, completionHandler: (resultObject: AnyObject?, error: NSError?) -> Void) {
        
        var encoding = ParameterEncoding.JSON
        if parameterEncoding == WrapperAlamofireParameterEncoding.URL { encoding = ParameterEncoding.URL }
        
        let method = Method(rawValue: httpMethod.rawValue)!
        Alamofire.manager.request(method, url, parameters: parameters, encoding: encoding, headers: nil).responseJSON { (response) -> Void in
            
            switch response.result {
            case .Failure(let error):
                completionHandler(resultObject: .None, error: error)
                
            case .Success(let value):
                completionHandler(resultObject: value, error: .None)
            }
        }
    }
}