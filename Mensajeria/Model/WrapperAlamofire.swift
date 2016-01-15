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
    
    private init() {}
    
    func request(httpMethod: WrapperAlamofireHTTPMethod, url: URLStringConvertible, parameterEncoding: WrapperAlamofireParameterEncoding, parameters: [String : AnyObject]? = nil, completionHandler: (resultObject: Result<AnyObject, NSError>) -> Void) {
        
        //var encoding = ParameterEncoding.JSON
        //if parameterEncoding == WrapperAlamofireParameterEncoding.URL { encoding = ParameterEncoding.URL }
        
        let encoding: ParameterEncoding
        switch parameterEncoding {
        case .URL:
            encoding = .URL
        case .JSON:
            encoding = .JSON
        }
        
        let method = Method(rawValue: httpMethod.rawValue)!
        Alamofire.manager.request(method, url, parameters: parameters, encoding: encoding).responseJSON { (response) -> Void in
            
            completionHandler(resultObject: response.result)
    
            /*switch response.result {
            case .Failure(let error):
                completionHandler(resultObject: .None, error: error)
                
            case .Success(let value):
                completionHandler(resultObject: value, error: .None)
            }*/
        }
    }
}