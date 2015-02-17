//
//  LoginViewController.swift
//  Mensajeria
//
//  Created by Developer on 4/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var mensajeriaLabel: UILabel!
    @IBOutlet weak var userTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setupUI() {
        /*mensajeriaLabel.layer.shadowColor = UIColor.blackColor().CGColor
        mensajeriaLabel.layer.shadowOpacity = 0.4
        mensajeriaLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        mensajeriaLabel.layer.shouldRasterize = true
        mensajeriaLabel.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        enterButton.layer.shadowColor = UIColor.blackColor().CGColor
        enterButton.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        enterButton.layer.shadowOpacity = 0.5
        enterButton.layer.shadowRadius = 1.0
        enterButton.layer.shouldRasterize = true
        enterButton.layer.rasterizationScale = UIScreen.mainScreen().scale*/
        
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
        println("entre al gotorequestttt")
        let revealViewController = storyboard?.instantiateViewControllerWithIdentifier("revealViewController") as SWRevealViewController
        presentViewController(revealViewController, animated: true, completion: nil)
    }
    
    //MARK: Notification Handlers 
    
    func keyboardWillShow() {
        //Move textfields up
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: .CurveLinear,
            animations: { () -> Void in
                self.containerView.transform = CGAffineTransformMakeTranslation(0.0, -78.0)
        }, completion: nil)
    }
    
    func keyboardWillHide() {
        //Move textfield down
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: .CurveLinear,
            animations: { () -> Void in
                self.containerView.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
}

//MARK: UITextfieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
