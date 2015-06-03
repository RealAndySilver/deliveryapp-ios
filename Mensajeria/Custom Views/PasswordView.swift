//
//  PasswordView.swift
//  Mensajeria
//
//  Created by Developer on 23/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class PasswordView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var newPasswordTextfield: UITextField!
    private let nibName = "PasswordView"
    private var opacityView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        alpha = 0.0
        transform = CGAffineTransformMakeScale(0.5, 0.5)
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: nibName, bundle: NSBundle.mainBundle())
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    func showInWindow(theWindow: UIWindow) {
        opacityView = UIView(frame:theWindow.frame)
        opacityView.backgroundColor = UIColor.blackColor()
        opacityView.alpha = 0.0
        theWindow.addSubview(opacityView)
        theWindow.addSubview(self)
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.alpha = 1.0
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.opacityView.alpha = 0.7
            
        }, completion: nil)
    }
    
    func closeView() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.alpha = 0.0
            self.transform = CGAffineTransformMakeScale(0.5, 0.5)
            self.opacityView.alpha = 0.0
        }) { (success) -> Void in
            self.opacityView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    @IBAction func acceptButtonPressed() {
        if passwordsAreCorrect() {
            changePasswordInServer()
        }
    }
    
    func passwordsAreCorrect() -> Bool {
        if count(newPasswordTextfield.text) > 0 && count(confirmPasswordTextfield.text) > 0 {
            if newPasswordTextfield.text == confirmPasswordTextfield.text {
                return true
                
            } else {
                UIAlertView(title: "Oops!", message: "Las contraseñas no coinciden", delegate: nil, cancelButtonTitle: "Ok").show()
                return false
            }
            
        } else {
            UIAlertView(title: "Oops!", message: "Hay campos sin completar", delegate: nil, cancelButtonTitle: "Ok").show()
            return false
        }
    }
    
    //MARK: Server Stuff 
    
    func changePasswordInServer() {
        MBProgressHUD.showHUDAddedTo(self, animated: true)
        let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        println("token: \(token)")
        let encodedPass = newPasswordTextfield.text.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(.allZeros)
        Alamofire.manager.request(.PUT, "\(Alamofire.newPasswordServiceURL)/\(token)", parameters: ["password" : encodedPass!], encoding: .URL).responseJSON { (request, response, json, error) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self, animated: true)
            if error != nil {
                //Error
                println("HUbo un error en el new password: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar cambiar la contraseña. Revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            
            } else {
                //Success 
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("respuesta true del new pass: \(jsonResponse)")
                    UIAlertView(title: "", message: "Tu clave se ha modificado con éxito!", delegate: self, cancelButtonTitle: "Ok").show()
                    
                } else {
                    println("Resputa false del new pass: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un problema al intentar cambiar la contraseña. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
}

//MARK: UIAlertViewDelegate

extension PasswordView: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //Success alert...close this view
        closeView()
    }
}

//MARK: UITextfieldDelegate

extension PasswordView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
