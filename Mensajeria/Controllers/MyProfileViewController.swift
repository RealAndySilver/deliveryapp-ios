//
//  MyProfileViewController.swift
//  Mensajeria
//
//  Created by Developer on 11/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {

    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        nameTextfield.text = User.sharedInstance.name
        lastNameTextfield.text = User.sharedInstance.lastName
        phoneTextfield.text = User.sharedInstance.mobilePhone
    }
    
    //MARK: Actions
    
    @IBAction func saveChangesPressed() {
        if formIsCorrect() {
            updateUserInServer()
        } else {
            UIAlertView(title: "Oops!", message: "Hay campos vacíos", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    //MARK: Server Stuff 
    
    func updateUserInServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        Alamofire.manager.request(.PUT, "\(Alamofire.updateUserServiceURL)/\(User.sharedInstance.identifier)", parameters: ["name" : nameTextfield.text, "lastname" : lastNameTextfield.text, "mobilephone" : phoneTextfield.text], encoding: .URL).responseJSON { (request, response, json, error) in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error != nil {
                //Error
                println("Error en el update user: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar actualizar el usuario. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    //Success response, update our user object
                    User.sharedInstance.updateUserWithJSON(jsonResponse["response"])
                    println("Resputa true del update user: \(jsonResponse)")
                    UIAlertView(title: "", message: "Usuario actualizado de forma exitosa!", delegate: nil, cancelButtonTitle: "Ok").show()
                    
                } else {
                    //False response
                    println("respuesta false del update user: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un problema al intentar actualizar tus datos, por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    //MARK: Form Validation 
    
    func formIsCorrect() -> Bool {
        if countElements(nameTextfield.text) > 0 && countElements(lastNameTextfield.text) > 0 && countElements(phoneTextfield.text) > 0 {
            return true
        }
        return false
    }
}
