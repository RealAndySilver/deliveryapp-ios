//
//  LoginViewController.swift
//  Mensajeria
//
//  Created by Developer on 4/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Actions
    
    @IBAction func enterButtonPressed() {
        //Check if the user has filled all the fields
        if formIsCorrect() {
            loginUserInServer()
            
        } else {
            UIAlertView(title: "Oops!", message: "Debes completar todos los datos", delegate: nil, cancelButtonTitle:"Ok").show()
        }
    }
    
    @IBAction func createAccountButtonPressed() {
    
    }
    
    @IBAction func forgotPassButtonPressed() {
    
    }
    
    //MARK: Form Stuff
    
    func formIsCorrect() -> Bool {
        return countElements(userTextfield.text) > 0 && countElements(passwordTextfield.text) > 0 ? true : false
    }
    
    //MARK: Server stuff
    
    func loginUserInServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        //Encode password
        let encodedPassword = passwordTextfield.text.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        
        //Make the login request to the server
        Alamofire.manager.request(.PUT, Alamofire.loginWebServiceURL, parameters: ["email" : userTextfield.text, "password" : encodedPassword!], encoding: ParameterEncoding.URL).responseJSON { (request, response, json, error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error != nil {
                //something wrong happened
                println("Error en el login: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar iniciar sesión. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                
            } else {
                //Success
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue == true {
                    println("success en el login: \(jsonResponse)")
                    User.sharedInstance.updateUserWithJSON(jsonResponse["response"])
                    self.goToRequestServiceVC()
                    //saveUserWithDictionary
                    
                } else {
                    println("respuesta false en el login: \(jsonResponse)")
                    if jsonResponse["error_id"].intValue == 0 {
                        //Usuario no encontrado
                        UIAlertView(title: "Oops!", message: "Usuario no encontrado", delegate: nil, cancelButtonTitle: "Ok").show()
                    } else if jsonResponse["error_id"].intValue == 1 {
                        //Usuario no confirmado 
                        UIAlertView(title: "Oops!", message: "Tu cuenta no ha sido confirmada. Por favor revisa el correo que te fue enviado al momento de crear tu cuenta", delegate: nil, cancelButtonTitle: "Ok").show()
                    }
                }
            }
        }
    }
    
    //MARK: Navigation 
    
    func goToRequestServiceVC() {
        let mainNavController = storyboard?.instantiateViewControllerWithIdentifier("MainNavController") as UINavigationController
        presentViewController(mainNavController, animated: true, completion: nil)
    }
}

//MARK: UITextfieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
