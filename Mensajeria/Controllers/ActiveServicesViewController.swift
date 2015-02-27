//
//  ActiveServicesViewController.swift
//  Mensajeria
//
//  Created by Developer on 13/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ActiveServicesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    //var activeItems = [DeliveryItem]()
    var requestedItems = [DeliveryItem]()
    var acceptedItems = [DeliveryItem]()
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getActiveDeliveryItems()
    }
    
    deinit {
        println("me cerreeeeee")
    }
    
    func setupUI() {
        tableView.rowHeight = 185.0
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        //Reveal button
        if revealViewController() != nil {
            revealButtonItem.target = revealViewController()
            revealButtonItem.action = "revealToggle:"
        }
    }
    
    //MARK: Actions
    
    @IBAction func updateAvailableServices(sender: AnyObject) {
        getActiveDeliveryItems()
    }
    
    
    //MARK: Server Stuff
    
    func getActiveDeliveryItems() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        Alamofire.manager.request(.GET, "\(Alamofire.activeItemsServiceURL)/\(User.sharedInstance.identifier)").responseJSON { (request, response, json, error) in
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            if error != nil {
                println("Error en el get active services: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al acceder a los servicios activos. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Resputa correcta del get active services: \(jsonResponse)")
                    let deliveryItems = jsonResponse["response"]
                    var tempArray = [DeliveryItem]()
                    for i in 0..<deliveryItems.count {
                        let deliveryItem = DeliveryItem(deliveryItemJSON: deliveryItems[i])
                        println("delivery item parseadooo: \(deliveryItem.description)")
                        tempArray.append(deliveryItem)
                    }
                    
                    func itemIsRequested(deliveryItem: DeliveryItem) -> Bool {
                        if deliveryItem.overallStatus == "requested" {
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    func itemIsAccepted(deliveryItem: DeliveryItem) -> Bool {
                        if deliveryItem.overallStatus == "started" {
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    self.requestedItems = tempArray.filter(itemIsRequested)
                    self.acceptedItems = tempArray.filter(itemIsAccepted)
                    self.tableView.reloadData()
                    
                } else {
                    println("Respuesta false del get active services: \(jsonResponse)")
                }
            }
        }
    }
}

extension ActiveServicesViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Servicios Sin Aceptar"
        } else {
            return "Servicios Aceptados"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return requestedItems.count
        } else {
            return acceptedItems.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ActiveServiceCell") as ActiveServiceCell
        
        if indexPath.section == 0 {
            cell.serviceNameLabel.text = requestedItems[indexPath.row].name
            cell.deliveryAddressLabel.text = requestedItems[indexPath.row].deliveryObject.address
            cell.pickupAdressLabel.text = requestedItems[indexPath.row].pickupObject.address
        } else {
            cell.serviceNameLabel.text = acceptedItems[indexPath.row].name
            cell.deliveryAddressLabel.text = acceptedItems[indexPath.row].deliveryObject.address
            cell.pickupAdressLabel.text = acceptedItems[indexPath.row].pickupObject.address
        }
        return cell
    }
}

//MARK: UITableViewDelegate

extension ActiveServicesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let serviceAcceptedVC = storyboard?.instantiateViewControllerWithIdentifier("ServiceAccepted") as ServiceAcceptedViewController
        if indexPath.section == 0 {
            serviceAcceptedVC.deliveryItem = requestedItems[indexPath.row]
        } else {
            serviceAcceptedVC.deliveryItem = acceptedItems[indexPath.row]
        }
        serviceAcceptedVC.presentedFromFindingServiceVC = false
        serviceAcceptedVC.presentedFromFinishedServicesVC = false
        serviceAcceptedVC.delegate = self
        navigationController?.pushViewController(serviceAcceptedVC, animated: true)
    }
}

//MARK: ServiceAcceptedDelegate

extension ActiveServicesViewController: ServiceAcceptedDelegate {
    func serviceUpdated() {
        println("Me llego el delegate")
        //Update our services
        getActiveDeliveryItems()
    }
}
