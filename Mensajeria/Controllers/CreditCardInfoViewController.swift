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
    let documentTypes = ["NIT", "CC", "CE", "TI", "PPN"]
    enum DocumentType: String {
        case NIT, CC, CE, TI, PPN
    }
    
    //Outlets
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var documentTypeTextField: UITextField!
    @IBOutlet weak var documentNumberTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var creditCardTextField: UITextField!
    @IBOutlet weak var creditCardImageView: UIImageView!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var securityCodeTextField: UITextField!
    
    var pressedDeletedKeyOnExpirationTextField = false
    
    enum TextFieldType: Int {
        case CreditCardNumber = 3, ExpirationDate = 1, SecurityCode = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creditCardTextField.addTarget(self, action: "creditCardNumberChanged:", forControlEvents: .EditingChanged)
        expirationDateTextField.addTarget(self, action: "expirationDateChanged:", forControlEvents: UIControlEvents.EditingChanged)
        
        if let _ = username, _ = password {
            self.navigationItem.hidesBackButton = true;
        }
        
        let documentTypePicker = UIPickerView()
        documentTypePicker.dataSource = self
        documentTypePicker.delegate = self
        documentTypeTextField.inputView = documentTypePicker
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(documentTypeDoneButtonPressed))
        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.size.width, height: 44.0))
        toolbar.setItems([doneBarButton], animated: false)
        documentTypeTextField.inputAccessoryView = toolbar
    }
    
    //MARK: Actions 
    
    @IBAction func tapGestureDetected(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func documentTypeDoneButtonPressed() {
        view.endEditing(true)
    }
    
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
        if !RegexValidator.stringIsAValidName(nameTextField.text) {
            AlertPresenter.presentBasicAlertWithMessage("Error en el campo Nombre", cancelButtonTitle: "Ok", overViewController: self)
            return
        }
        
        if !RegexValidator.stringIsAValidName(lastNameTextField.text) {
            AlertPresenter.presentBasicAlertWithMessage("Error en el campo Apellido", cancelButtonTitle: "Ok", overViewController: self)
            return
        }
        
        if !RegexValidator.stringIsAValidEmail(emailTextField.text) {
            AlertPresenter.presentBasicAlertWithMessage("Error en el campo Email", cancelButtonTitle: "Ok", overViewController: self)
            return
        }
        
        if !RegexValidator.stringIsAValidName(cityTextField.text) {
            AlertPresenter.presentBasicAlertWithMessage("Error en el campo Ciudad", cancelButtonTitle: "Ok", overViewController: self)
            return
        }
        
        if let addressText = addressTextField.text where addressText.characters.count == 0 {
            AlertPresenter.presentBasicAlertWithMessage("Error en el campo Dirección", cancelButtonTitle: "Ok", overViewController: self)
            return
        }
        
        if let documentTypeText = documentTypeTextField.text,
            let _ = DocumentType(rawValue: documentTypeText) {
            
            if let documentNumberText = documentNumberTextField.text where documentNumberText.characters.count == 0 {
                AlertPresenter.presentBasicAlertWithMessage("Error en el campo Número de Documento", cancelButtonTitle: "Ok", overViewController: self)
                return
            }
            /*switch selectedDocumentType {
            case .CC:
                if !RegexValidator.stringIsAValidCC(documentNumberTextField.text) {
                    AlertPresenter.presentBasicAlertWithMessage("Error en número de documento (CC)", cancelButtonTitle: "Ok", overViewController: self)
                    return
                }
            case .CE:
                if !RegexValidator.stringIsAValidCE(documentNumberTextField.text) {
                    AlertPresenter.presentBasicAlertWithMessage("Error en número de documento (CE)", cancelButtonTitle: "Ok", overViewController: self)
                    return
                }
            case .NIT:
                if !RegexValidator.stringIsAValidNIT(documentNumberTextField.text) {
                    AlertPresenter.presentBasicAlertWithMessage("Error en número de documento (NIT)", cancelButtonTitle: "Ok", overViewController: self)
                    return
                }
            case .PPN:
                if !RegexValidator.stringIsAValidPPN(documentNumberTextField.text) {
                    AlertPresenter.presentBasicAlertWithMessage("Error en número de documento (PPN)", cancelButtonTitle: "Ok", overViewController: self)
                    return
                }
            case .TI:
                if !RegexValidator.stringIsAValidTI(documentNumberTextField.text) {
                    AlertPresenter.presentBasicAlertWithMessage("Error en número de documento (TI)", cancelButtonTitle: "Ok", overViewController: self)
                    return
                }
            }*/
            
            
        } else {
            AlertPresenter.presentBasicAlertWithMessage("Error en el tipo de documento", cancelButtonTitle: "Ok", overViewController: self)
            return
        }

        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let parameters = ["user_id": User.sharedInstance.identifier, "card_number": creditCardTextField.text!, "cvv": securityCodeTextField.text!, "exp_date": expirationDateTextField.text!, "franchise": "visa", "card_holder_first_name": nameTextField.text!, ".card_holder_last_name": lastNameTextField.text!, "card_holder_address": addressTextField.text!, "card_holder_city": cityTextField.text!, "card_holder_doc_type": documentTypeTextField.text!, "card_holder_doc_number": documentNumberTextField.text!, "card_holder_email": emailTextField.text!]
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
                    var message = "Hubo un error al agregar tu tarjeta. Por favor revisa que los datos sean correctos e intenta de nuevo"
                    
                    if let responseMessage = jsonResponse["message"].string {
                        message = responseMessage
                    }
                    
                    let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
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

/////////////////////////////////////////////////////////////

extension CreditCardInfoViewController: UIPickerViewDataSource {
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return documentTypes.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension CreditCardInfoViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return documentTypes[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        documentTypeTextField.text = documentTypes[row]
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
            
            if (textField.text!.isEmpty && (string != "0" && string != "1" && string != "")) {
                return false
            }
            
            if (textField.text! == "1" && (string != "1" && string != "2" && string != "0" && string != "")) {
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