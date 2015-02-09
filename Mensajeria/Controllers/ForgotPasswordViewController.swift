//
//  ForgotPasswordViewController.swift
//  Mensajeria
//
//  Created by Developer on 9/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Actions 
    
    @IBAction func sendButtonPressed() {
        if countElements(emailTextfield.text) > 0 {
            sendRecoverPetitionToServer()
            
        } else {
            UIAlertView(title: "Oops!", message: "No has escrito el correo electrónico", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    //MARK: Server Stuff 
    
    func sendRecoverPetitionToServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        Alamofire.manager.request(.GET, "\(Alamofire.recoverPassServiceURL)/\(emailTextfield.text)").responseJSON { (request, response, json, error) in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error != nil {
                //There was an error
                println("Error: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error, por favor revisa que tu dirección de correo electrónico sea correcta", delegate: nil, cancelButtonTitle: "Ok").show()
            
            } else {
                //Successfull service request
                let jsonResponse = JSON(json!)
                println(jsonResponse)
            }
        }
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
