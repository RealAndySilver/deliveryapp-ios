//
//  ChangePasswordViewController.swift
//  Mensajeria
//
//  Created by Developer on 23/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var actualPasswordTextfield: UITextField!
    @IBOutlet weak var newPasswordTextfield: UITextField!
    @IBOutlet weak var confirmNewPassTextfield: UITextField!
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Actions 
    
    @IBAction func changeButtonPressed() {
        if formIsCorrect() {
            changePassword()
        }
    }
    
    //MARK: Server Stuff
    
    func changePassword() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        let encodedPreviousPass = actualPasswordTextfield.text.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(.allZeros)
        let encodedNewPass = newPasswordTextfield.text.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(.allZeros)
        
        Alamofire.manager.request(.PUT, "\(Alamofire.changePasswordServiceURL)/\(User.sharedInstance.identifier)", parameters: ["password" : encodedPreviousPass!, "new_password" : encodedNewPass!], encoding: .URL).responseJSON { (request, response, json, error) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            
            if error != nil {
                //Error 
                println("hubo un error en el change pass: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar cambiar tu contraseña. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Success
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Resputa true del change pass: \(jsonResponse)")
                    UIAlertView(title: "", message: "Tu contraseña se ha cambiado de forma exitosa!", delegate: self, cancelButtonTitle: "Ok").show()
                    
                } else {
                    println("respuesta false del change pass: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Tu contraseña actual no es correcta. Por favor revisa", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    //MARK: Form Validation
    
    func formIsCorrect() -> Bool {
        if count(newPasswordTextfield.text) > 0 && count(confirmNewPassTextfield.text) > 0 && count(actualPasswordTextfield.text) > 0 {
            if newPasswordTextfield.text == confirmNewPassTextfield.text {
                return true
                
            } else {
                UIAlertView(title: "Oops!", message: "Tu nueva contraseña no coincide en los dos campos requeridos", delegate: nil, cancelButtonTitle: "Ok").show()
                return false
            }
            
        } else {
            UIAlertView(title: "Oops!", message: "Hay campos incorrectos", delegate: nil, cancelButtonTitle: "Ok").show()
            return false
        }
    }
}

//MARK: UITextfieldDelegate

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: UIAlertViewDelegate

extension ChangePasswordViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //Success changing password alert 
        navigationController?.popViewControllerAnimated(true)
    }
}
