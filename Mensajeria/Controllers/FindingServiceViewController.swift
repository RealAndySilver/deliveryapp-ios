//
//  FindingServiceViewController.swift
//  Mensajeria
//
//  Created by Developer on 9/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class FindingServiceViewController: UIViewController {

    var serviceID: String!
    var serviceRequestTimer: NSTimer!
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("id del servicio: \(serviceID)")
        navigationItem.hidesBackButton = true
        serviceRequestTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "checkServiceStatus", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        serviceRequestTimer.invalidate()
    }
    
    //MARK: Actions
    
    @IBAction func cancelServicePressed() {
        UIActionSheet(title: "¿Estás seguro de cancelar el servicio?", delegate: self, cancelButtonTitle: "Volver", destructiveButtonTitle: "Cancelar el servicio").showInView(view)
    }
    
    //MARK: Server Stuff
    
    func cancelServiceInServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        Alamofire.manager.request(.DELETE, "\(Alamofire.cancelRequestServiceURL)/\(serviceID)", parameters: ["user_id" : User.sharedInstance.identifier], encoding: .URL).responseJSON { (request, response, json, error) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error != nil {
                //There was an error
                println("Error en el cancel service: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un problema en el servidor. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Respuesta correcta del cancel service: \(jsonResponse)")
                    UIAlertView(title: "", message: "Servicio cancelado de manera exitosa!", delegate: nil, cancelButtonTitle: "Ok").show()
                    
                    //Cancel request check timer 
                    self.serviceRequestTimer.invalidate()
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    println("Respuesta false del cancel service: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al cancelar el servicio. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
            
        }
    }
    
    func checkServiceStatus() {
        println("Checkearé el statusssss")
        Alamofire.manager.request(.GET, "\(Alamofire.getDeliveryItemServiceURL)/54dbbe3ade9a5c2220000002").responseJSON { (request, response, json, error) in
            if error != nil {
                //There was an error 
                println("Error : \(error?.localizedDescription)")
            } else {
                //Success
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Succes json response: \(jsonResponse)")
                    //Check if the service was accepted by a messenger 
                    if jsonResponse["response"]["overall_status"].stringValue == "started" {
                        self.serviceRequestTimer.invalidate()
                        let deliveryItem = DeliveryItem(deliveryItemJSON: JSON(jsonResponse["response"].object))
                        if let messengerInfo = deliveryItem.messengerInfo {
                            self.goToServiceAcceptedWithDeliveryItem(deliveryItem)

                        } else {
                            println("Hubo algun error grave porque no me llego el objeto messenger info")
                        }
                    }
                    
                } else {
                    println("llego en status false el json response: \(jsonResponse)")
                }
            }
        }
    }
    
    //MARK: Navigation 
    
    func goToServiceAcceptedWithDeliveryItem(deliveryItem: DeliveryItem) {
        let serviceAcceptedVC = storyboard?.instantiateViewControllerWithIdentifier("ServiceAccepted") as ServiceAcceptedViewController
        serviceAcceptedVC.deliveryItem = deliveryItem
        navigationController?.pushViewController(serviceAcceptedVC, animated: true)
    }
}

extension FindingServiceViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            //Cancel Service in server
            cancelServiceInServer()
        }
    }
}
