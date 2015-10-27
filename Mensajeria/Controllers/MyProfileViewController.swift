//
//  MyProfileViewController.swift
//  Mensajeria
//
//  Created by Developer on 11/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {

    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    private var activeTextField: UITextField?
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        setupUI()
    }
    
    func setupUI() {
        nameTextfield.text = User.sharedInstance.name
        lastNameTextfield.text = User.sharedInstance.lastName
        phoneTextfield.text = User.sharedInstance.mobilePhone
        
        //Reveal button
        if revealViewController() != nil {
            revealButtonItem.target = revealViewController()
            revealButtonItem.action = "revealToggle:"
        }
    }
    
    //MARK: Actions
    
    @IBAction func tapDetected(sender: AnyObject) {
        activeTextField?.resignFirstResponder()
    }
    
    @IBAction func saveChangesPressed() {
        if formIsCorrect() {
            updateUserInServer()
        } else {
            UIAlertView(title: "Oops!", message: "Hay campos vacíos", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    //MARK: Server Stuff 
    
    func updateUserInServer() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.updateUserServiceURL)/\(User.sharedInstance.identifier)", methodType: "PUT", theParameters: ["name" : nameTextfield.text!, "lastname" : lastNameTextfield.text!, "mobilephone" : phoneTextfield.text!])
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            if case .Failure(let error) = response.result {
                //Error
                print("Error en el update user: \(error.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar actualizar el usuario. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    //Success response, update our user object
                    User.sharedInstance.updateUserWithJSON(jsonResponse["response"])
                    print("Resputa true del update user: \(jsonResponse)")
                    UIAlertView(title: "", message: "Usuario actualizado de forma exitosa!", delegate: nil, cancelButtonTitle: "Ok").show()
                    
                } else {
                    //False response
                    print("respuesta false del update user: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un problema al intentar actualizar tus datos, por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    //MARK: Form Validation 
    
    func formIsCorrect() -> Bool {
        if nameTextfield.text!.characters.count > 0 && lastNameTextfield.text!.characters.count > 0 && phoneTextfield.text!.characters.count > 0 {
            return true
        }
        return false
    }
}

//MARK: UITextfieldDelegate

extension MyProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
    }
}
