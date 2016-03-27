//
//  CreateAccountViewController.swift
//  Mensajeria
//
//  Created by Diego Fernando Vidal Illera on 2/5/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

//POST -> email, password, name, lastname, mobilephone

protocol CreateAccountViewControllerDelegate: class {
    func accountCreatedSuccessfullyWithUsername(username: String, password: String)
}

class CreateAccountViewController: UIViewController {
    weak var delegate: CreateAccountViewControllerDelegate?
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var cellphoneTextfield: UITextField!
    private var activeTextfield: UITextField?
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillFormInfo()
        setupUI()
    }
    
    //MARK: Custom Initialization stuff 
    
    func setupUI() {
        registerButton.layer.shadowColor = UIColor.blackColor().CGColor
        registerButton.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        registerButton.layer.shadowRadius = 1.0
        registerButton.layer.shadowOpacity = 0.4
    }
    
    func fillFormInfo() {
        if let formDic = NSUserDefaults.standardUserDefaults().objectForKey("formDic") as? [String: String!]{
            nameTextfield.text = formDic["name"]
            lastNameTextfield.text = formDic["lastName"]
            emailTextfield.text = formDic["email"]
            cellphoneTextfield.text = formDic["phone"]
        }
    }
    
    //MARK: Actions 
    
    @IBAction func tapDetected(sender: UITapGestureRecognizer) {
        if let activeTextfield = activeTextfield {
            activeTextfield.resignFirstResponder()
        }
    }
    
    @IBAction func registerButtonPressed() {
        if passwordsAreCorrect() {
            passwordTextfield.layer.borderWidth = 0.0
            confirmPasswordTextfield.layer.borderWidth = 0.0
            
            if emailIsCorrect() {
                if formIsCorrect() {
                    //Success...create account in server
                    createAccountInServer()
                    
                } else {
                    //Error
                    UIAlertView(title: "Oops!", message: "Hay campos incorrectos", delegate: nil, cancelButtonTitle: "Ok").show()
                }
                
            } else {
                UIAlertView(title: "Oops!", message: "El email está mal escrito. Por favor revisa", delegate: nil, cancelButtonTitle: "Ok").show()
            }
            
        } else {
            UIAlertView(title: "Oops!", message: "Las contraseñas no coinciden", delegate: nil, cancelButtonTitle: "Ok").show()
            passwordTextfield.layer.borderWidth = 1.0
            passwordTextfield.layer.borderColor = UIColor.redColor().CGColor
            
            confirmPasswordTextfield.layer.borderWidth = 1.0
            confirmPasswordTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
    }
    
    @IBAction func cancelButtonPressed() {
        saveFormInfo()
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Server Stuff 
    
    func loginUserInServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        //App token
        var token = ""
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let theToken = appDelegate.appToken {
            token = theToken
        }
        
        //Encode password
        let encodedPassword = passwordTextfield.text!.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        
        //Make the login request to the server
        Alamofire.manager.request(.PUT, Alamofire.loginWebServiceURL, parameters: ["email" : emailTextfield.text!, "password" : encodedPassword!, "device_info" : ["type" : UIDevice.currentDevice().model, "os" : "iOS", "token" : token, "name" : UIDevice.currentDevice().name]], encoding: ParameterEncoding.URL).responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if case .Failure(let error) = response.result  {
                //Something wrong happened
                print("Error en el login: \(error.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar iniciar sesión. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                /*NSUserDefaults.standardUserDefaults().removeObjectForKey("UserInfo")
                NSUserDefaults.standardUserDefaults().removeObjectForKey("UserPass")
                NSUserDefaults.standardUserDefaults().synchronize()*/
                
            } else {
                //Success
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue == true {
                    print("success en el login: \(jsonResponse)")
                    User.sharedInstance.updateUserWithJSON(jsonResponse["response"])
                    User.sharedInstance.password = self.passwordTextfield.text!
                    NSUserDefaults.standardUserDefaults().setObject(self.passwordTextfield.text!, forKey: "UserPass")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    let alert = UIAlertView(title: "", message: "Tu usuario se ha creado exitosamente.", delegate: self, cancelButtonTitle: "Ok")
                    alert.tag = 1
                    alert.show()
                    /*NSUserDefaults.standardUserDefaults().setObject(password, forKey: "UserPass")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.goToRequestServiceVC()*/
                    
                } else {
                    /*NSUserDefaults.standardUserDefaults().removeObjectForKey("UserInfo")
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("UserPass")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    print("respuesta false en el login: \(jsonResponse)")
                    if jsonResponse["error_id"].intValue == 0 {
                        //Usuario no encontrado
                        UIAlertView(title: "Oops!", message: "Usuario no encontrado", delegate: nil, cancelButtonTitle: "Ok").show()
                    } else if jsonResponse["error_id"].intValue == 1 {
                        //Usuario no confirmado
                        UIAlertView(title: "Oops!", message: "Tu cuenta no ha sido confirmada. Por favor revisa el correo que te fue enviado al momento de crear tu cuenta", delegate: nil, cancelButtonTitle: "Ok").show()
                    }*/
                }
            }
        }
    }
    
    func createAccountInServer() {
        /*let alert = UIAlertView(title: "", message: "Tu usuario se ha creado exitosamente.", delegate: self, cancelButtonTitle: "Ok")
        alert.tag = 1
        alert.show()
        return;*/
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        //Encode password
        let encodedPassword = passwordTextfield.text!.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions([])
        
        Alamofire.manager.request(.POST, Alamofire.createUserServiceURL, parameters: ["email" : emailTextfield.text!, "password" : encodedPassword!, "name" : nameTextfield.text!, "lastname" : lastNameTextfield.text!, "mobilephone" : cellphoneTextfield.text!], encoding: .URL).responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if case .Failure(let error) = response.result {
                //Error
                UIAlertView(title: "", message: "Hubo un error al intentar crear la cuenta. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                print("Error en el Create User: \(error.localizedDescription)")
                
            } else {
                //Success 
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue == true {
                    print("Respuesta true del create: \(jsonResponse)")
                    //Show confirmation email alert
                    self.loginUserInServer()
                   
                } else {
                    if jsonResponse["err"]["code"].intValue == 11000 {
                        //The email already exists
                       UIAlertView(title: "", message: "Ya existe una cuenta con ese correo electrónico. Por favor ingresa otro correo.", delegate: nil, cancelButtonTitle: "Ok").show()
                    } else {
                        UIAlertView(title: "", message: "Hay un problema en los datos. Por favor revisa que el formulario esté completo e intenta de nuevo.", delegate: nil, cancelButtonTitle: "Ok").show()
                    }
                    print("Respuesta false del create: \(jsonResponse)")
                }
            }
        }
    }
    
    //MARK: Form Validation
    
    func emailIsCorrect() -> Bool {
        if RegexValidator.stringIsAValidEmail(emailTextfield.text!) {
            emailTextfield.layer.borderWidth = 0.0
            return true
            
        } else {
            emailTextfield.layer.borderWidth = 1.0
            emailTextfield.layer.borderColor = UIColor.redColor().CGColor
            return false
        }
    }
    
    func passwordsAreCorrect() -> Bool {
        if passwordTextfield.text!.characters.count > 0 && confirmPasswordTextfield.text!.characters.count > 0 && passwordTextfield.text == confirmPasswordTextfield.text {
            return true
        } else {
            return false
        }
    }
    
    func formIsCorrect() -> Bool {
        var nameIsCorrect = false
        var lastNameIsCorrect = false
        var emailIsCorrect = false
        var phoneIsCorrect = false
        
        if nameTextfield.text!.characters.count > 0 {
            nameIsCorrect = true
            nameTextfield.layer.borderWidth = 0.0
            
        } else {
            nameTextfield.layer.borderWidth = 1.0
            nameTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if lastNameTextfield.text!.characters.count > 0 {
            lastNameIsCorrect = true
            lastNameTextfield.layer.borderWidth = 0.0

        } else {
            lastNameTextfield.layer.borderColor = UIColor.redColor().CGColor
            lastNameTextfield.layer.borderWidth = 1.0
        }
        
        if emailTextfield.text!.characters.count > 0{
            emailIsCorrect = true
            emailTextfield.layer.borderWidth = 0.0

        } else {
            emailTextfield.layer.borderWidth = 1.0
            emailTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if cellphoneTextfield.text!.characters.count > 0 {
            phoneIsCorrect = true
            cellphoneTextfield.layer.borderWidth = 0.0
        } else {
            cellphoneTextfield.layer.borderWidth = 1.0
            cellphoneTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        return nameIsCorrect && emailIsCorrect && lastNameIsCorrect && phoneIsCorrect ? true : false
    }
    
    //MARK: User Defaults Saving 
    
    func saveFormInfo() {
        let formInfo = ["name" : nameTextfield.text!, "lastName" : lastNameTextfield.text!, "email" : emailTextfield.text!, "phone" : cellphoneTextfield.text!]
        NSUserDefaults.standardUserDefaults().setObject(formInfo, forKey: "formDic")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

//MARK: UITextfieldDelegate

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextfield = textField
    }
}

//MARK: UIViewControllerTransitioningDelegate 

extension CreateAccountViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let shrinkAnimateController = ShrinkDismissAnimationController()
        return shrinkAnimateController
    }
}

//MARK: UIAlertViewDelegate

extension CreateAccountViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 1 {
            let creditCardInfoVC = storyboard?.instantiateViewControllerWithIdentifier("CreditCardInfo") as! CreditCardInfoViewController
            creditCardInfoVC.username = emailTextfield.text
            creditCardInfoVC.password = passwordTextfield.text
            navigationController?.pushViewController(creditCardInfoVC, animated: true)
            //Account created successfully alert
            /*dismissViewControllerAnimated(true, completion: { () -> Void in
                self.delegate?.accountCreatedSuccessfullyWithUsername(self.emailTextfield.text!, password: self.passwordTextfield.text!)
            })*/
        }
    }
}
