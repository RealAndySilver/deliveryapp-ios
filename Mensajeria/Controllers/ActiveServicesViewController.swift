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
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        setupUI()
        getActiveDeliveryItems()
    }
    
    deinit {
        print("me cerreeeeee")
    }
    
    func setupUI() {
        tableView.rowHeight = 236.0
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
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.activeItemsServiceURL)/\(User.sharedInstance.identifier)/{\"name\":\"-date_created\"}", methodType: "GET")
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            if case .Failure(let error) = response.result {
                print("Error en el get active services: \(error.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al acceder a los servicios activos. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    print("Resputa correcta del get active services: \(jsonResponse)")
                    let deliveryItems = jsonResponse["response"]
                    var tempArray = [DeliveryItem]()
                    for i in 0..<deliveryItems.count {
                        let deliveryItem = DeliveryItem(deliveryItemJSON: deliveryItems[i])
                        print("delivery item parseadooo: \(deliveryItem.description)")
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
                    print("Respuesta false del get active services: \(jsonResponse)")
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
            return "Servicios por asignar (\(requestedItems.count))"
        } else {
            return "Servicios asignados a mensajero (\(acceptedItems.count))"
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ActiveServiceCell") as! ActiveServiceCell
        
        if indexPath.section == 0 {
            cell.serviceNameLabel.text = requestedItems[indexPath.row].name
            cell.deliveryAddressLabel.text = requestedItems[indexPath.row].deliveryObject.address
            cell.pickupAdressLabel.text = requestedItems[indexPath.row].pickupObject.address
            cell.dateCreatedLabel.text = requestedItems[indexPath.row].dateCreatedString
        } else {
            cell.serviceNameLabel.text = acceptedItems[indexPath.row].name
            cell.deliveryAddressLabel.text = acceptedItems[indexPath.row].deliveryObject.address
            cell.pickupAdressLabel.text = acceptedItems[indexPath.row].pickupObject.address
            cell.dateCreatedLabel.text = acceptedItems[indexPath.row].dateCreatedString
        }
        return cell
    }
}

//MARK: UITableViewDelegate

extension ActiveServicesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let serviceAcceptedVC = storyboard?.instantiateViewControllerWithIdentifier("ServiceAccepted") as! ServiceAcceptedViewController
        if indexPath.section == 0 {
            serviceAcceptedVC.deliveryItem = requestedItems[indexPath.row]
        } else {
            serviceAcceptedVC.deliveryItem = acceptedItems[indexPath.row]
        }
        serviceAcceptedVC.presentedFromPushNotification = false 
        serviceAcceptedVC.presentedFromFindingServiceVC = false
        serviceAcceptedVC.presentedFromFinishedServicesVC = false
        serviceAcceptedVC.delegate = self
        navigationController?.pushViewController(serviceAcceptedVC, animated: true)
    }
}

//MARK: ServiceAcceptedDelegate

extension ActiveServicesViewController: ServiceAcceptedDelegate {
    func serviceUpdated() {
        print("Me llego el delegate")
        //Update our services
        getActiveDeliveryItems()
    }
}
