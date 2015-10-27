//
//  FinishedServicesViewController.swift
//  Mensajeria
//
//  Created by Developer on 16/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class FinishedServicesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    var finishedItems = [DeliveryItem]()
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        setupUI()
        getFinishedServices()
    }
    
    //MARK: Custom Initialization Stuff
    
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
    
    @IBAction func updateFinishedServices(sender: AnyObject) {
        getFinishedServices()
    }
    
    
    //MARK: Server Connection
    
    func getFinishedServices() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.finishedItemsServiceURL)/\(User.sharedInstance.identifier)", methodType: "GET")
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (request, response, json, error) in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            if error != nil {
                //There was an error 
                println("Error en el get finished items: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error intentando acceder a los servicios terminados. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle:"Ok").show()
            } else {
                //Successfull response
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Respuesta true del get finished items: \(jsonResponse)")
                    let deliveryItems = jsonResponse["response"]
                    var tempArray = [DeliveryItem]()
                    for i in 0..<deliveryItems.count {
                        let deliveryItem = DeliveryItem(deliveryItemJSON: deliveryItems[i])
                        println("delivery item parseadooo: \(deliveryItem.description)")
                        tempArray.append(deliveryItem)
                    }
                    self.finishedItems = tempArray
                    self.tableView.reloadData()
                    
                } else {
                    println("Respuesta false del get finished items: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un problema al acceder a los servicios terminados. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
}

//MARK: UITableViewDataSource 

extension FinishedServicesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finishedItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FinishedServiceCell") as! ActiveServiceCell
        cell.serviceNameLabel.text = finishedItems[indexPath.row].name
        cell.pickupAdressLabel.text = finishedItems[indexPath.row].pickupObject.address
        cell.deliveryAddressLabel.text = finishedItems[indexPath.row].deliveryObject.address
        return cell
    }
}

//MARK: UITableViewDelegate

extension FinishedServicesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let serviceAcceptedVC = storyboard?.instantiateViewControllerWithIdentifier("ServiceAccepted") as! ServiceAcceptedViewController
        serviceAcceptedVC.deliveryItem = finishedItems[indexPath.row]
        serviceAcceptedVC.presentedFromPushNotification = false
        serviceAcceptedVC.presentedFromFindingServiceVC = false
        serviceAcceptedVC.presentedFromFinishedServicesVC = true
        navigationController?.pushViewController(serviceAcceptedVC, animated: true)
    }
}
