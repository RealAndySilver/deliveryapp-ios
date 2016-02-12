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
        if emailTextfield.text!.characters.count > 0 {
            sendRecoverPetitionToServer()
            
        } else {
            UIAlertView(title: "Oops!", message: "No has escrito el correo electrónico", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    //MARK: Server Stuff 
    
    func sendRecoverPetitionToServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        print("url de la peticioooonnnnnn: \(Alamofire.recoverPassServiceURL)/\(emailTextfield.text)")
        Alamofire.manager.request(.GET, "\(Alamofire.recoverPassServiceURL)/\(emailTextfield.text!)").responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if case .Failure(let error) = response.result {
                //There was an error
                print("Error: \(error.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error, por favor revisa que tu dirección de correo electrónico sea correcta", delegate: nil, cancelButtonTitle: "Ok").show()
            
            } else {
                //Successfull service request
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    print("respuesta true del recover: \(jsonResponse)")
                    UIAlertView(title: "", message: "Se te ha enviado un correo electrónico con las instrucciones para reestablecer tu contraseña", delegate: nil, cancelButtonTitle: "Ok").show()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    print("respuesta false del recover: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al enviar el correo electrónico. Asegúrate de que el email es correcto", delegate: nil, cancelButtonTitle: "Ok").show()
                }
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
