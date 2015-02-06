//
//  RequestServiceViewController.swift
//  Mensajeria
//
//  Created by Diego Fernando Vidal Illera on 2/5/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class RequestServiceViewController: UIViewController {
    
    enum TextfieldName: Int {
        case pickupTextfield = 1, finalTextfield, dayHourTextfield, shipmentValueTextfield
    }
    
    @IBOutlet weak var pickupAddressTextfield: UITextField!
    @IBOutlet weak var finalAddressTextfield: UITextField!
    @IBOutlet weak var idaYVueltaSwitch: UISwitch!
    @IBOutlet weak var dayHourTextfield: UITextField!
    @IBOutlet weak var shipmentValueTextfield: UITextField!
    @IBOutlet weak var instructionsTextView: UITextView!
    lazy var dateFormatter: NSDateFormatter = {
        println("entre a nicializarrr")
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle
        formatter.locale = NSLocale.currentLocale()
        return formatter
    }()
    
    //Constants
    let savedPickupAdressesKey = "pickupAddresses"
    let savedDestinationAdressesKey = "destinationAddresses"
    let maxAllowedSavedAddresses = 10
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0, green: 102.0/255.0, blue: 134.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        setupUI()
        
        /*if let array = NSUserDefaults.standardUserDefaults().objectForKey(savedPickupAdressesKey) as? [[String : String]] {
            let firstDate = array[0]
            let savedDate = firstDate["dateSaved"] as NSDate
            println("Fecha guardada: \(savedDate)")
        }*/
    }
    
    //MARK: UI Setup
    
    func setupUI() {
        instructionsTextView.layer.borderWidth = 1.0
        instructionsTextView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        instructionsTextView.layer.cornerRadius = 10.0
        
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: "dateChanged:", forControlEvents: .ValueChanged)
        dayHourTextfield.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.size.width, height: 44.0))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissPickers")
        toolBar.setItems([doneButton], animated: false)
        
        dayHourTextfield.inputAccessoryView = toolBar
        shipmentValueTextfield.inputAccessoryView = toolBar
    }
    
    //MARK: Actions 
    
    @IBAction func exitButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addAdditionalAddressPressed() {
    
    }
    
    @IBAction func addressHistoryPressed() {
   
    }
    
    @IBAction func acceptButtonPressed() {
        if formIsCorrect() {
            saveAddressInUserDefaults()
            
        } else {
            UIAlertView(title: "Oops!", message: "No has completado todos los campos", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    func dateChanged(datePicker: UIDatePicker) {
        dayHourTextfield.text = dateFormatter.stringFromDate(datePicker.date)
    }
    
    func dismissPickers() {
        dayHourTextfield.resignFirstResponder()
        shipmentValueTextfield.resignFirstResponder()
    }
    
    //MARK: Form Validation
    
    func formIsCorrect() -> Bool {
        var pickupAddressIsCorrect = false
        var finalAddressIsCorrect = false
        var dayAndHourIsCorrect = false
        var instructionsAreCorrect = false
    
        if countElements(pickupAddressTextfield.text) > 0 {
            pickupAddressIsCorrect = true
            pickupAddressTextfield.layer.borderWidth = 0.0
        } else {
            pickupAddressTextfield.layer.borderWidth = 1.0
            pickupAddressTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if countElements(finalAddressTextfield.text) > 0 {
            finalAddressIsCorrect = true
            finalAddressTextfield.layer.borderWidth = 0.0
        } else {
            finalAddressTextfield.layer.borderColor = UIColor.redColor().CGColor
            finalAddressTextfield.layer.borderWidth = 1.0
        }
        
        if countElements(dayHourTextfield.text) > 0 {
            dayAndHourIsCorrect = true
            dayHourTextfield.layer.borderWidth = 0.0
        } else {
            dayHourTextfield.layer.borderWidth = 1.0
            dayHourTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if countElements(instructionsTextView.text) > 0 {
            instructionsAreCorrect = true
            instructionsTextView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        } else {
            instructionsTextView.layer.borderColor = UIColor.redColor().CGColor
        }
        
        return pickupAddressIsCorrect && finalAddressIsCorrect && dayAndHourIsCorrect && instructionsAreCorrect ? true : false
    }
    
    //MARK: Navigation
    
    func goToMapVC() {
        if let mapVC = storyboard?.instantiateViewControllerWithIdentifier("Map") as? MapViewController {
            mapVC.onAddressAvailable = {[weak self]
                (theAddress) in
                if let weakSelf = self {
                    weakSelf.updatePickupAddress(theAddress)
                }
            }
            navigationController?.pushViewController(mapVC, animated: true)
        }
    }
    
    //MARK: Custom Stuff
    
    func updatePickupAddress(address: String) {
        pickupAddressTextfield.text = address
    }
    
    //MARK: Data Saving 
    
    func saveAddressInUserDefaults() {
        //Save pickup address 
        var pickupAddressDic = [String : String]()
        pickupAddressDic["dateSaved"] = dateFormatter.stringFromDate(NSDate())
        pickupAddressDic["address"] = pickupAddressTextfield.text
        
        if var pickupAddresses = NSUserDefaults.standardUserDefaults().objectForKey(savedPickupAdressesKey) as? [[String: String]] {
            println("Ya existia el arreglo de direcciones")
            pickupAddresses.insert(pickupAddressDic, atIndex: 0)
            if pickupAddresses.count > maxAllowedSavedAddresses {
                pickupAddresses.removeLast()
            }
            NSUserDefaults.standardUserDefaults().setObject(pickupAddresses, forKey: savedPickupAdressesKey)
            
        } else {
            println("No existía el arreglo de direcciones")
            let addressesArray = [pickupAddressDic]
            NSUserDefaults.standardUserDefaults().setObject(addressesArray, forKey: savedPickupAdressesKey)
        }
        
        //Save destination address
        var destinationAddressesDic = [String : String]()
        destinationAddressesDic["dateSaved"] = dateFormatter.stringFromDate(NSDate())
        destinationAddressesDic["address"] = finalAddressTextfield.text
        
        if var destinationAddresses = NSUserDefaults.standardUserDefaults().objectForKey(savedDestinationAdressesKey) as? [[String : String]] {
            destinationAddresses.insert(destinationAddressesDic, atIndex: 0)
            if destinationAddresses.count > maxAllowedSavedAddresses {
                destinationAddresses.removeLast()
            }
            NSUserDefaults.standardUserDefaults().setObject(destinationAddresses, forKey: savedDestinationAdressesKey)
        } else {
            let destinationAddressesArray = [destinationAddressesDic]
            NSUserDefaults.standardUserDefaults().setObject(destinationAddressesArray, forKey: savedDestinationAdressesKey)
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddressHistorySegue" {
            let addressHistoryVC = segue.destinationViewController as AddressHistoryViewController
            addressHistoryVC.delegate = self
        }
    }
}

//MARK: UITextfieldDelegate

extension RequestServiceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        println("Empzaré a editar el textfield \(textField.tag)")
        if textField.tag == TextfieldName.pickupTextfield.rawValue {
            goToMapVC()
            return false
        } else {
            return true
        }
    }
}

//MARK: UITextviewDelegate

extension RequestServiceViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK: AddressHistoryDelegate

extension RequestServiceViewController: AddressHistoryDelegate {
    func addressSelected(adress: String, forPickupLocation: Bool) {
        println("me llego la direccion: \(adress) y la pondre en el pickup: \(forPickupLocation)")
        if forPickupLocation {
            pickupAddressTextfield.text = adress
        } else {
            finalAddressTextfield.text = adress
        }
    }
}


