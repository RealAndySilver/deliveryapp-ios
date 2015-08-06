//
//  AbortedServicesViewController.swift
//  Mensajeria
//
//  Created by Developer on 20/03/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class AbortedServicesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    var abortedServices = [DeliveryItem]()
    var selectedService = 0

    //MARK: Life cycle & Initialization stuff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getAbortedServices()
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
    
    //MARK: Server stuff
    
    func enableService(deliveryItem: DeliveryItem) {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.restartItemServiceURL)/\(deliveryItem.identifier)", methodType: "PUT", theParameters: ["user_id" : User.sharedInstance.identifier])
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (request, response, json, error) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            
            if error != nil {
                //Error
                println("Error en el restart service: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar habilitar de nuevo el servicio. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Success
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    UIAlertView(title: "", message: "El servicio se ha habilitado de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                    
                } else {
                    println("Respuesta false del restart item: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar habilitar de nuevo el servicio.", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    func deleteService(deliveryItem: DeliveryItem) {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.cancelRequestServiceURL)/\(deliveryItem.identifier)/\(User.sharedInstance.identifier)", methodType: "DELETE")
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (request, response, json, error) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            
            if error != nil {
                //Error
                println("Error borrando el servicio: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al borrar el servicio. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Success
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("respuesta true del delete service: \(jsonResponse)")
                    
                } else {
                    println("Respuesta false del delete service: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "El pedido no pudo ser eliminado", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
            
        }
    }
    
    func getAbortedServices() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.abortedItemsServiceURL)/\(User.sharedInstance.identifier)", methodType: "GET")
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (request, response, json, error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            if error != nil {
                //Error 
                println("Error obteniendo los aborted items: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar acceder a tus servicios abortados. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Success
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Resputa true del aborted: \(jsonResponse)")
                    let tempDeliveryItems = jsonResponse["response"]
                    var tempAbortedService = [DeliveryItem]()
                    for i in 0..<tempDeliveryItems.count {
                        let deliveryItem = DeliveryItem(deliveryItemJSON: tempDeliveryItems[i])
                        tempAbortedService.append(deliveryItem)
                    }
                    self.abortedServices = tempAbortedService
                    self.tableView.reloadData()
                    
                } else {
                    println("Respuesta false del aborted: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al acceder a tus servicios abortados. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
}

//MARK: UITableViewDataSource

extension AbortedServicesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return abortedServices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AbortedServiceCell", forIndexPath: indexPath) as! ActiveServiceCell
        cell.pickupAdressLabel.text = abortedServices[indexPath.row].pickupObject.address
        cell.deliveryAddressLabel.text = abortedServices[indexPath.row].deliveryObject.address
        cell.serviceNameLabel.text = abortedServices[indexPath.row].name
        return cell
    }
}

//MARK: UITableViewDelegate

extension AbortedServicesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedService = indexPath.row
        
        //Show options alert
        //UIAlertView(title: "", message: "¿Que deseas hacer?", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Habilitar servicio de nuevo", "Eliminar servicio").show()
        
        let serviceAcceptedVC = storyboard?.instantiateViewControllerWithIdentifier("ServiceAccepted") as! ServiceAcceptedViewController
        serviceAcceptedVC.deliveryItem = abortedServices[indexPath.row]
        serviceAcceptedVC.presentedFromPushNotification = false
        serviceAcceptedVC.presentedFromFindingServiceVC = false
        serviceAcceptedVC.presentedFromFinishedServicesVC = false
        serviceAcceptedVC.presentedFromAbortedService = true
        serviceAcceptedVC.delegate = self
        navigationController?.pushViewController(serviceAcceptedVC, animated: true)
    }
}

//MARK: ServiceAcceptedDelegate

extension AbortedServicesViewController: ServiceAcceptedDelegate {
    func serviceUpdated() {
        println("Me llego el delegate*******************************************************")
        //Update our services
        getAbortedServices()
    }
}

//MARK: UIAlertViewDelegate

extension AbortedServicesViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        println("button index: \(buttonIndex)")
        if buttonIndex == 1 {
            //Habilitar servicio
            enableService(abortedServices[selectedService])
            
        } else if buttonIndex == 2 {
            //Eliminar servicio
            deleteService(abortedServices[selectedService])
        }
    }
}
