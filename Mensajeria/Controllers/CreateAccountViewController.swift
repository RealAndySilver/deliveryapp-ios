//
//  CreateAccountViewController.swift
//  Mensajeria
//
//  Created by Diego Fernando Vidal Illera on 2/5/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

//POST -> email, password, name, lastname, mobilephone

class CreateAccountViewController: UIViewController {

    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var cellphoneTextfield: UITextField!
    
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
        
        cancelButton.layer.shadowColor = UIColor.blackColor().CGColor
        cancelButton.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        cancelButton.layer.shadowRadius = 1.0
        cancelButton.layer.shadowOpacity = 0.4
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func termsConditionsPressed() {
    
    }
    
    //MARK: Server Stuff 
    
    func createAccountInServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        //Encode password
        let encodedPassword = passwordTextfield.text.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(.allZeros)
        
        Alamofire.manager.request(.POST, Alamofire.createUserServiceURL, parameters: ["email" : emailTextfield.text, "password" : encodedPassword!, "name" : nameTextfield.text, "lastname" : lastNameTextfield.text, "mobilephone" : cellphoneTextfield.text], encoding: .URL).responseJSON { (request, response, json, error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error != nil {
                //Error
                println("Error en el Create User: \(error?.localizedDescription)")
            } else {
                //Success 
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue == true {
                    println("Respuesta true del create: \(jsonResponse)")
                    //Show confirmation email alert
                    UIAlertView(title: "", message: "Tu usuario se ha creado exitosamente. Por favor confirma tu cuenta desde el correo que se te ha enviado.", delegate: nil, cancelButtonTitle: "Ok").show()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    println("Respuesta false del create: \(jsonResponse)")
                }
            }
        }
    }
    
    //MARK: Form Validation
    
    func emailIsCorrect() -> Bool {
        if RegexValidator.stringIsAValidEmail(emailTextfield.text) {
            emailTextfield.layer.borderWidth = 0.0
            return true
            
        } else {
            emailTextfield.layer.borderWidth = 1.0
            emailTextfield.layer.borderColor = UIColor.redColor().CGColor
            return false
        }
    }
    
    func passwordsAreCorrect() -> Bool {
        if countElements(passwordTextfield.text) > 0 && countElements(confirmPasswordTextfield.text) > 0 && passwordTextfield.text == confirmPasswordTextfield.text {
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
        
        if countElements(nameTextfield.text) > 0 {
            nameIsCorrect = true
            nameTextfield.layer.borderWidth = 0.0
            
        } else {
            nameTextfield.layer.borderWidth = 1.0
            nameTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if countElements(lastNameTextfield.text) > 0 {
            lastNameIsCorrect = true
            lastNameTextfield.layer.borderWidth = 0.0

        } else {
            lastNameTextfield.layer.borderColor = UIColor.redColor().CGColor
            lastNameTextfield.layer.borderWidth = 1.0
        }
        
        if countElements(emailTextfield.text) > 0{
            emailIsCorrect = true
            emailTextfield.layer.borderWidth = 0.0

        } else {
            emailTextfield.layer.borderWidth = 1.0
            emailTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if countElements(cellphoneTextfield.text) > 0 {
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
        let formInfo = ["name" : nameTextfield.text, "lastName" : lastNameTextfield.text, "email" : emailTextfield.text, "phone" : cellphoneTextfield.text]
        NSUserDefaults.standardUserDefaults().setObject(formInfo, forKey: "formDic")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    //MARK: Navigation 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TermsConditionsSegue" {
            let termsConditionsVC = segue.destinationViewController as UIViewController
            termsConditionsVC.transitioningDelegate = self
        }
    }
}

//MARK: UITextfieldDelegate

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: UIViewControllerTransitioningDelegate 

extension CreateAccountViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let shrinkAnimateController = ShrinkDismissAnimationController()
        return shrinkAnimateController
    }
}
