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
    
    override func viewDidAppear(animated: Bool) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    //MARK: Actions
    
    @IBAction func enterButtonPressed() {
        //Check if the user has filled all the fields
        if formIsCorrect() {
            //Login user
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
}

//MARK: UITextfieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
