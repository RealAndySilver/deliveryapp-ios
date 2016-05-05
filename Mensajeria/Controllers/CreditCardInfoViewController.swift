//
//  CreditCardInfoViewController.swift
//  Mensajeria
//
//  Created by Diego Vidal on 15/03/16.
//  Copyright © 2016 iAm Studio. All rights reserved.
//

import UIKit

protocol CreditCardInfoViewControllerDelegate: class {
    func creditCardCreated(creditCard: CreditCard)
}

class CreditCardInfoViewController: UIViewController {

    weak var delegate: CreditCardInfoViewControllerDelegate?
    var username: String?
    var password: String?
    
    //Outlets
    @IBOutlet weak var creditCardTextField: UITextField!
    @IBOutlet weak var creditCardImageView: UIImageView!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var securityCodeTextField: UITextField!
    
    var pressedDeletedKeyOnExpirationTextField = false
    
    enum TextFieldType: Int {
        case CreditCardNumber = 0, ExpirationDate, SecurityCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creditCardTextField.addTarget(self, action: "creditCardNumberChanged:", forControlEvents: .EditingChanged)
        expirationDateTextField.addTarget(self, action: "expirationDateChanged:", forControlEvents: UIControlEvents.EditingChanged)
        
        if let _ = username, _ = password {
            self.navigationItem.hidesBackButton = true;
        }
    }
    
    //MARK: Actions 
    
    func creditCardNumberChanged(textField: UITextField) {
        if let text = textField.text where text.characters.count == 4 {
            getFranchiseFromServer()
        }
    }
    
    func expirationDateChanged(textField: UITextField) {
        print("[CreditCardViewController] : Expiration date changed: \(textField.text!)")
    
        if let text = textField.text where text.characters.count == 2 {
            if pressedDeletedKeyOnExpirationTextField {
                textField.text = nil
                
            } else {
                textField.text = text + "/"
            }
        }
        
        else if let text = textField.text where text.characters.count == 5 {
            //User ended writing the expiration date, make the CVV textfield the first responder 
            securityCodeTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func addLaterButtonPressed() {
        view.endEditing(true)
        if let username = self.username, password = self.password {
            //We came from the CreateAccountVC
            navigationController?.dismissViewControllerAnimated(true) {
                NSNotificationCenter.defaultCenter().postNotificationName("AddCardLaterNotification", object: nil, userInfo: ["username": username, "password": password])
            }
        
        } else {
            //We came from the Payment hamburguer menu 
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func addCreditCardButtonPressed() {
        view.endEditing(true)
        addCreditCardToServer()
    }
    
    ////////////////////////////////////////////////////////////////
    
    func getFranchiseFromServer() {
        let firstFourCharacters = creditCardTextField.text!.substringToIndex(creditCardTextField.text!.startIndex.advancedBy(4))
        print(firstFourCharacters)
        let mutableURLRequest = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.getFranchiseByBin)/\(firstFourCharacters)", methodType: "GET")
        
        if mutableURLRequest == nil {
            print("Error creando el request, está en nil")
            return
        }
        
        Alamofire.manager.request(mutableURLRequest!).responseJSON { response in
            switch response.result {
            case .Success(let value):
                print("Success in the get franchise: \(value)")
                if let franchise = value["response"] as? String,
                    let creditCardIdentifier = CreditCardIdentifier(rawValue: franchise) {
                        self.creditCardImageView.image = UIImage(creditCardIdentifier: creditCardIdentifier)
                }
            case .Failure(let error):
                print("Error in the get franchise: \(error)")
            }
        }
    }
    
    func addCreditCardToServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let parameters = ["user_id": User.sharedInstance.identifier, "card_number": creditCardTextField.text!, "cvv": securityCodeTextField.text!, "exp_date": expirationDateTextField.text!, "franchise": "visa"]
        let mutableURLRequest = NSMutableURLRequest.createURLRequestWithHeaders(Alamofire.createPaymentMethod, methodType: "POST", theParameters: parameters)
        
        if mutableURLRequest == nil {
            print("Error creando el request, está en nil")
            return
        }
        
        Alamofire.manager.request(mutableURLRequest!).responseJSON { response in
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            switch response.result {
            case .Success(let value):
                let jsonResponse = JSON(value)
                print("Response of the add card: \(jsonResponse)")
                if jsonResponse["status"].boolValue == true {
                    print("\(self.dynamicType): Successfull reponse of the create payment method: \(jsonResponse)")
                    let creditCard = CreditCard(creditCardJson: jsonResponse["response"])
                    self.delegate?.creditCardCreated(creditCard)
                    
                    if let username = self.username, password = self.password {
                        //We came from the CreateAccountVC
                        self.navigationController?.dismissViewControllerAnimated(true) {
                            NSNotificationCenter.defaultCenter().postNotificationName("AddCardLaterNotification", object: nil, userInfo: ["username": username, "password": password])
                        }
                    } else {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                
                } else {
                    let alert = UIAlertController(title: "Oops!", message: "Hubo un error al agregar tu tarjeta. Por favor revisa que los datos sean correctos e intenta de nuevo", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            
            case .Failure(let error):
                let alert = UIAlertController(title: "Oops!", message: "Hubo un problema de conexión al agregar tu tarjeta. Por favor revisa que estés conectado a internet e intenta de nuevo", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                print("\(self.dynamicType): Error in the create payment method: \(error.localizedDescription)")
            }
        }
    }
}

//////////////////////////////////////////////////////////////

extension CreditCardInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == TextFieldType.ExpirationDate.rawValue {
            print("Replacement string: \(string)")
            
            if textField.text!.length == 5 && !string.isEmpty {
                return false
            }
            
            print("[CreditCardInfoViewController] : Expiration date text: \(textField.text)")
            print("[CreditCardInfoViewControlelr] : New String: \(string)")
            
            pressedDeletedKeyOnExpirationTextField = string.isEmpty ? true : false
            
            return true
        }
        
        else if textField.tag == TextFieldType.SecurityCode.rawValue {
            if textField.text!.length == 4 && !string.isEmpty {
                return false
            }
            return true
        }
        
        else if textField.tag == TextFieldType.CreditCardNumber.rawValue {
            if textField.text!.length == 16 && !string.isEmpty {
                return false
            }
            return true
        }
        
        return true
    }
}