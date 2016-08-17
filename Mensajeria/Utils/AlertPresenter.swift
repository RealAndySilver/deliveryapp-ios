//
//  AlertPresenter.swift
//  Mensajeria
//
//  Created by Diego Vidal on 17/08/16.
//  Copyright © 2016 iAm Studio. All rights reserved.
//

import UIKit

class AlertPresenter {
    static func presentBasicAlertWithMessage(message: String, cancelButtonTitle: String, overViewController viewController: UIViewController) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}