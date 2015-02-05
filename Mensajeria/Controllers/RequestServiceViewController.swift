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
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0, green: 102.0/255.0, blue: 134.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    //MARK: Actions 
    
    @IBAction func addAdditionalAddressPressed() {
    
    }
    
    @IBAction func addressHistoryPressed() {
   
    }
    
    @IBAction func acceptButtonPressed() {
    
    }
    
    //MARK: Navigation
    
    func goToMapVC() {
        if let mapVC = storyboard?.instantiateViewControllerWithIdentifier("Map") as? MapViewController {
            navigationController?.pushViewController(mapVC, animated: true)
        }
    }
}

//MARK: UITextfieldDelegate

extension RequestServiceViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        println("Empzaré a editar el textfield \(textField.tag)")
        if textField.tag == TextfieldName.pickupTextfield.rawValue {
            goToMapVC()
        }
        return false
    }
}


