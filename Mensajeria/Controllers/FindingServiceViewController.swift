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
    let loadingView = MONActivityIndicatorView()
    var serviceRequestTimer: NSTimer!
    @IBOutlet weak var containerView: UIView!
    var firstTimeViewAppeared = true
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("id del servicio: \(serviceID)")
        serviceRequestTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "checkServiceStatus", userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.onWaitingForConfirmationScreen = true
        }
        
        if firstTimeViewAppeared {
            setupUI()
            firstTimeViewAppeared = false
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        serviceRequestTimer.invalidate()
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.onWaitingForConfirmationScreen = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        loadingView.stopAnimating()
    }
    
    func setupUI() {
        //Setup searching indicator view
        loadingView.delegate = self
        containerView.addSubview(loadingView)
        loadingView.startAnimating()
        loadingView.center = CGPoint(x: containerView.bounds.size.width/2.0, y: containerView.bounds.size.height - 90.0)
    }
    
    //MARK: Actions
    
    @IBAction func cancelServicePressed() {
        UIActionSheet(title: "¿Estás seguro de cancelar el servicio?", delegate: self, cancelButtonTitle: "Volver", destructiveButtonTitle: "Cancelar el servicio").showInView(view)
    }
    
    //MARK: Server Stuff
    
    func cancelServiceInServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        print("url del cancel: \(Alamofire.cancelRequestServiceURL)/\(serviceID)")
        
        let mutableURLRequest = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.cancelRequestServiceURL)/\(serviceID)/\(User.sharedInstance.identifier)", methodType: "DELETE")
        if mutableURLRequest == nil { return }
        
        Alamofire.manager.request(mutableURLRequest!).responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if case .Failure(let error) = response.result {
                //There was an error
                print("Error en el cancel service: \(error.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un problema en el servidor. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    print("Respuesta correcta del cancel service: \(jsonResponse)")
                    UIAlertView(title: "", message: "Servicio cancelado de manera exitosa!", delegate: nil, cancelButtonTitle: "Ok").show()
                    
                    //Cancel request check timer 
                    self.serviceRequestTimer.invalidate()
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    print("Respuesta false del cancel service: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al cancelar el servicio. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
            
        }
    }
    
    func checkServiceStatus() {
        print("Checkearé el statusssss")
        let mutableURLRequest = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.getDeliveryItemServiceURL)/\(serviceID)", methodType: "GET")
        if mutableURLRequest == nil { return }
        
        Alamofire.manager.request(mutableURLRequest!).responseJSON { (response) -> Void in
        
            if case .Failure(let error) = response.result {
                //There was an error 
                print("Error : \(error.localizedDescription)")
            } else {
                //Success
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    print("Succes json response: \(jsonResponse)")
                    //Check if the service was accepted by a messenger 
                    if jsonResponse["response"]["overall_status"].stringValue == "started" {
                        self.serviceRequestTimer.invalidate()
                        let deliveryItem = DeliveryItem(deliveryItemJSON: JSON(jsonResponse["response"].object))
                        if let _ = deliveryItem.messengerInfo {
                            self.goToServiceAcceptedWithDeliveryItem(deliveryItem)

                        } else {
                            print("Hubo algun error grave porque no me llego el objeto messenger info")
                        }
                    }
                    
                } else {
                    print("llego en status false el json response: \(jsonResponse)")
                }
            }
        }
    }
    
    //MARK: Navigation 
    
    func goToServiceAcceptedWithDeliveryItem(deliveryItem: DeliveryItem) {
        let serviceAcceptedVC = storyboard?.instantiateViewControllerWithIdentifier("ServiceAccepted") as! ServiceAcceptedViewController
        serviceAcceptedVC.deliveryItem = deliveryItem
        serviceAcceptedVC.presentedFromPushNotification = false
        serviceAcceptedVC.presentedFromFindingServiceVC = true
        serviceAcceptedVC.presentedFromFinishedServicesVC = false
        navigationController?.pushViewController(serviceAcceptedVC, animated: true)
    }
}

//MARK: MONActivityViewDelegate

extension FindingServiceViewController: MONActivityIndicatorViewDelegate {
    func activityIndicatorView(activityIndicatorView: MONActivityIndicatorView!, circleBackgroundColorAtIndex index: UInt) -> UIColor! {
        return UIColor.getSecondaryAppColor()
    }
}

//MARK: UIActionSheetDelegate

extension FindingServiceViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            //Cancel Service in server
            cancelServiceInServer()
        }
    }
}
