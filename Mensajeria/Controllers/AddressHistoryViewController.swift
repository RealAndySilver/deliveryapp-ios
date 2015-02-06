//
//  AddressHistoryViewController.swift
//  Mensajeria
//
//  Created by Developer on 6/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

protocol AddressHistoryDelegate {
    func addressSelected(adress: String, forPickupLocation: Bool)
}

class AddressHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let savedPickupAdressesKey = "pickupAddresses"
    let savedDestinationAdressesKey = "destinationAddresses"
    var delegate: AddressHistoryDelegate?
    var selectedAddress = ""
    var savedAddressesArray: [[String : String]] = [] {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
    }
    var savedDestinationAddressesArray: [[String : String]] = [] {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        }
    }
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSavedAddresses()
    }
    
    //MARK: Custom Initialization Stuff
    
    func getSavedAddresses() {
        if let pickupAddresses = NSUserDefaults.standardUserDefaults().objectForKey(savedPickupAdressesKey) as? [[String: String]] {
            savedAddressesArray = pickupAddresses
        }
        
        if let destinationAddresses = NSUserDefaults.standardUserDefaults().objectForKey(savedDestinationAdressesKey) as? [[String : String]] {
            savedDestinationAddressesArray = destinationAddresses
        }
    }
}

//MARK: UITableViewDataSource

extension AddressHistoryViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
            case 0:
                return "Direcciones de Recogida"
            case 1:
                return "Direcciones de Entrega"
            default:
                return ""
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
            case 0:
                return savedAddressesArray.count
            case 1:
                return savedDestinationAddressesArray.count
            default:
                return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddressCell") as? UITableViewCell
        
        if indexPath.section == 0 {
            cell!.textLabel?.text = savedAddressesArray[indexPath.row]["address"]
            cell!.detailTextLabel?.text = savedAddressesArray[indexPath.row]["dateSaved"]
        } else {
            cell!.textLabel?.text = savedDestinationAddressesArray[indexPath.row]["address"]
            cell!.detailTextLabel?.text = savedDestinationAddressesArray[indexPath.row]["dateSaved"]
        }
        return cell!
    }
}

//MARK: UITableViewDelegate

extension AddressHistoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let selectedAddressIndex = indexPath.row
        
        if indexPath.section == 0 {
            selectedAddress = savedAddressesArray[indexPath.row]["address"]!
        } else {
            selectedAddress = savedDestinationAddressesArray[indexPath.row]["address"]!
        }
        
        UIAlertView(title: "", message: "Usar la dirección '\(selectedAddress)' en: ", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Dirección de Recogida", "Dirección de Entrega").show()
    }
}

//MARK: UIAlertViewDelegate

extension AddressHistoryViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 2 {
            //Direccion de entrega button pressed
            delegate?.addressSelected(selectedAddress, forPickupLocation: false)
            navigationController?.popViewControllerAnimated(true)
            
        } else if buttonIndex == 1 {
            //Direccion de recogida button pressed
            delegate?.addressSelected(selectedAddress, forPickupLocation: true)
            navigationController?.popViewControllerAnimated(true)
        }
    }
}