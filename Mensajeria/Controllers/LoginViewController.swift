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
    var userIsLoggedIn = false
    var firstTimeViewAppears = true
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstTimeViewAppears {
            checkIfUserIsLoggedIn()
            firstTimeViewAppears = false
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if let userObject = NSUserDefaults.standardUserDefaults().objectForKey("UserInfo") as? [String : String] {
            //Save user object in our user singleton
            User.sharedInstance.updateUserWithJSON(JSON(userObject))
            
            //The user object exists, so go to the main screen (but with a delay of 2 seconds)
            userIsLoggedIn = true
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "loginUserInServer", userInfo: nil, repeats: false)
        }
    }
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setupUI() {
        mensajeriaLabel.layer.shadowColor = UIColor.blackColor().CGColor
        mensajeriaLabel.layer.shadowOpacity = 0.4
        mensajeriaLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        mensajeriaLabel.layer.shouldRasterize = true
        mensajeriaLabel.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        enterButton.layer.shadowColor = UIColor.blackColor().CGColor
        enterButton.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        enterButton.layer.shadowOpacity = 0.5
        enterButton.layer.shadowRadius = 1.0
        enterButton.layer.shouldRasterize = true
        enterButton.layer.rasterizationScale = UIScreen.mainScreen().scale
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
        return count(userTextfield.text) > 0 && count(passwordTextfield.text) > 0 ? true : false
    }
    
    //MARK: Server stuff
    
    func loginUserInServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        if let userObject = NSUserDefaults.standardUserDefaults().objectForKey("UserInfo") as? [String : String] {
            userIsLoggedIn = true
        } else {
            userIsLoggedIn = false
        }
        
        //App token
        var token = ""
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let theToken = appDelegate.appToken {
            token = theToken
        }
        
        var email = ""
        var password = ""
        if userIsLoggedIn {
            email = User.sharedInstance.email
            password = NSUserDefaults.standardUserDefaults().objectForKey("UserPass") as! String
            
        } else {
            email = userTextfield.text
            password = passwordTextfield.text
        }
        
        println("email: \(email)")
        println("pass: \(password)")
        
        //Encode password
        let encodedPassword = password.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        
        //Make the login request to the server
        Alamofire.manager.request(.PUT, Alamofire.loginWebServiceURL, parameters: ["email" : email, "password" : encodedPassword!, "device_info" : ["type" : UIDevice.currentDevice().model, "os" : "iOS", "token" : token, "name" : UIDevice.currentDevice().name]], encoding: ParameterEncoding.URL).responseJSON { (request, response, json, error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error != nil {
                //Something wrong happened
                println("Error en el login: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar iniciar sesión. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                NSUserDefaults.standardUserDefaults().removeObjectForKey("UserInfo")
                NSUserDefaults.standardUserDefaults().removeObjectForKey("UserPass")
                NSUserDefaults.standardUserDefaults().synchronize()
                
            } else {
                //Success
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue == true {
                    println("success en el login: \(jsonResponse)")
                    User.sharedInstance.updateUserWithJSON(jsonResponse["response"])
                    User.sharedInstance.password = password
                    NSUserDefaults.standardUserDefaults().setObject(password, forKey: "UserPass")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.goToRequestServiceVC()
                    //saveUserWithDictionary
                    
                } else {
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("UserInfo")
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("UserPass")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
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
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        println("entre al gotorequestttt")
        let revealViewController = storyboard?.instantiateViewControllerWithIdentifier("revealViewController") as! SWRevealViewController
        revealViewController.transitioningDelegate = self
        presentViewController(revealViewController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateAccountSegue" {
            let createAccountVC = segue.destinationViewController as! CreateAccountViewController
            createAccountVC.transitioningDelegate = self
            createAccountVC.delegate = self
        }
    }
    
    //MARK: Notification Handlers 
    
    func keyboardWillShow() {
        //Move textfields up
        let distanceToMove: CGFloat
        if view.bounds.size.height <= 568 {
            distanceToMove = 78.0
        } else {
            distanceToMove = 90.0
        }
        
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: .CurveLinear,
            animations: { () -> Void in
                self.containerView.transform = CGAffineTransformMakeTranslation(0.0, -distanceToMove)
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

//MARK: UIViewControllerTransitionDelegate

extension LoginViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let shrinkAnimationController = ShrinkDismissAnimationController()
        return shrinkAnimationController
    }
}

//MARK: CreateAccountViewControllerDelegate

extension LoginViewController: CreateAccountViewControllerDelegate {
    func accountCreatedSuccessfullyWithUsername(username: String, password: String) {
        userTextfield.text = username
        passwordTextfield.text = password
        loginUserInServer()
    }
}
