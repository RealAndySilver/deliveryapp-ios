//
//  TermsConditionsViewController.swift
//  Mensajeria
//
//  Created by Diego Fernando Vidal Illera on 2/5/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class TermsConditionsViewController: UIViewController {

    @IBOutlet private weak var webView: UIWebView!
    var openingFromHamburguerMenu: Bool?
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "\(Alamofire.getTermsAndConditions)")!))
        
        if let openingFromHamburguerMenu = openingFromHamburguerMenu where openingFromHamburguerMenu == true {
            let closeBarButton = UIBarButtonItem(title: "Cerrar", style: .Plain, target: self, action: "dismissVC")
            navigationItem.leftBarButtonItem = closeBarButton
        }
    }
    
    func dismissVC() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
