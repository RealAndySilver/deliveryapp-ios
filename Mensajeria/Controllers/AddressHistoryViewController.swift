//
//  AddressHistoryViewController.swift
//  Mensajeria
//
//  Created by Developer on 6/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

protocol AddressHistoryDelegate: class {
    func addressSelected(adressDic: [String : AnyObject], forPickupLocation: Bool)
}

class AddressHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let savedPickupAdressesKey = "pickupAddresses"
    let savedDestinationAdressesKey = "destinationAddresses"
    weak var delegate: AddressHistoryDelegate?
    var selectedAddressDic: [String : AnyObject]!
    //var selectedAddress = ""
    var savedAddressesArray: [[String : AnyObject]] = [] {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
    }
    var savedDestinationAddressesArray: [[String : AnyObject]] = [] {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        }
    }
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        getSavedAddresses()
    }
    
    deinit {
        print("me cerreeeeeee")
    }
    
    //MARK: Custom Initialization Stuff
    
    func getSavedAddresses() {
        if let pickupAddresses = NSUserDefaults.standardUserDefaults().objectForKey(savedPickupAdressesKey) as? [[String: AnyObject]] {
            savedAddressesArray = pickupAddresses
        }
        
        if let destinationAddresses = NSUserDefaults.standardUserDefaults().objectForKey(savedDestinationAdressesKey) as? [[String : AnyObject]] {
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SavedAddressCell") as? AddressCell
        
        if indexPath.section == 0 {
            cell!.addressNameLabel.text = savedAddressesArray[indexPath.row]["address"] as? String
            cell!.dateSavedLabel.text = savedAddressesArray[indexPath.row]["dateSaved"] as? String
        } else {
            cell!.addressNameLabel.text = savedDestinationAddressesArray[indexPath.row]["address"] as? String
            cell!.dateSavedLabel.text = savedDestinationAddressesArray[indexPath.row]["dateSaved"] as? String
        }
        return cell!
    }
}

//MARK: UITableViewDelegate

extension AddressHistoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //let selectedAddressIndex = indexPath.row
        
        if indexPath.section == 0 {
            selectedAddressDic = savedAddressesArray[indexPath.row]
            //selectedAddress = savedAddressesArray[indexPath.row]["address"]!
        } else {
            selectedAddressDic = savedDestinationAddressesArray[indexPath.row]
            //selectedAddress = savedDestinationAddressesArray[indexPath.row]["address"]!
        }
        
        let addressName = selectedAddressDic["address"] as! String
        UIAlertView(title: "", message: "Usar la dirección '\(addressName)' en: ", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Dirección de Recogida", "Dirección de Entrega").show()
    }
}

//MARK: UIAlertViewDelegate

extension AddressHistoryViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 2 {
            //Direccion de entrega button pressed
            //delegate?.addressSelected(selectedAddressDic, forPickupLocation: false)
            //delegate?.addressSelected(selectedAddress, forPickupLocation: false)
            //navigationController?.popViewControllerAnimated(true)
            
            NSNotificationCenter.defaultCenter().postNotificationName("addressSelectedNotification", object: nil, userInfo: ["addressDic": selectedAddressDic, "pickupLocation": false])
            
        } else if buttonIndex == 1 {
            //Direccion de recogida button pressed
            //delegate?.addressSelected(selectedAddressDic, forPickupLocation: true)
            //delegate?.addressSelected(selectedAddress, forPickupLocation: true)
            //navigationController?.popViewControllerAnimated(true)
            
            NSNotificationCenter.defaultCenter().postNotificationName("addressSelectedNotification", object: nil, userInfo: ["addressDic": selectedAddressDic, "pickupLocation": true])
        }
        
        for viewController in navigationController!.viewControllers {
            if viewController.isKindOfClass(RequestServiceViewController.self) {
                navigationController!.popToViewController(viewController, animated: true)
                return
            }
        }
    }
}