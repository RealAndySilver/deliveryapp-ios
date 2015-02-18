//
//  ServiceAcceptedViewController.swift
//  Mensajeria
//
//  Created by Developer on 9/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit
import MessageUI

class ServiceAcceptedViewController: UIViewController {
    @IBOutlet weak var driverInfoTopContainer: ShadowedView!
    var noDriverLabel: UILabel!

    //Public Interface
    var deliveryItem: DeliveryItem!
    var presentedFromFindingServiceVC: Bool!
    
    @IBOutlet weak var serviceStatusLabel: UILabel!
    @IBOutlet weak var driverContainerView: UIView!
    @IBOutlet var buttonsCollection: [UIButton]!
    @IBOutlet weak var backToHomeButton: UIButton!
    @IBOutlet weak var cellphoneButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var shipmentDayLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var platesLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    var viewAppearedForTheFirstTime = true
    
    //MARK: View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if presentedFromFindingServiceVC == true {
            navigationItem.hidesBackButton = true
            backToHomeButton.hidden = false
        } else {
            backToHomeButton.hidden = true
            navigationItem.hidesBackButton = false
        }
        println("El delivery item: \(deliveryItem.deliveryItemDescription)")
        setupUI()
        fillUIWithDeliveryItemInfo()
    }
    
    //MARK: Custom Initialization Stuff
    
    func fillUIWithDeliveryItemInfo() {
        ////////////////////////////////////////////////////////////////////////
        //Set service info in the UI
        pickupLabel.text = deliveryItem.pickupObject.address
        deliveryLabel.text = deliveryItem.deliveryObject.address
        shipmentDayLabel.text = deliveryItem.pickupTimeString
        costLabel.text = "$\(deliveryItem.declaredValue)"
        nameLabel.text = deliveryItem.messengerInfo?.name
        if let theCellPhone = deliveryItem.messengerInfo?.mobilePhone {
            cellphoneButton.setTitle("Celular: \(theCellPhone)", forState: .Normal)
        }
        platesLabel.text = deliveryItem.messengerInfo?.plate
        
        switch deliveryItem.status {
        case "available":
            serviceStatusLabel.text = "BUSCANDO MENSAJERO"
        case "accepted":
            serviceStatusLabel.text = "ACEPTADO"
        case "in-transit":
            serviceStatusLabel.text = "EN TRÁNSITO"
        case "returning":
            serviceStatusLabel.text = "VOLVIENDO"
        case "returned":
            serviceStatusLabel.text = "DEVUELTO"
        case "delivered":
            serviceStatusLabel.text = "ENTREGADO"
        default:
            break
        }
        
        if deliveryItem.overallStatus == "requested" {
            driverContainerView.hidden = true
            noDriverLabel.hidden = false
        } else {
            driverContainerView.hidden = false
            noDriverLabel.hidden = true
        }
    }
    
    func setupUI() {
        ////////////////////////////////////////////////////////////////////
        for button in buttonsCollection {
            button.layer.shadowColor = UIColor.blackColor().CGColor
            button.layer.shadowOffset = CGSizeMake(0.0, 1.0)
            button.layer.shadowOpacity = 0.5
            button.layer.shadowRadius = 1.0
            button.layer.shouldRasterize = true
            button.layer.rasterizationScale = UIScreen.mainScreen().scale
        }
        
        //////////////////////////////////////////////////////////////////////
        //Create RatingView
        let ratingView = RatingView(frame: CGRect(x: photoImageView.frame.origin.x + photoImageView.frame.size.width + 10.0, y: photoImageView.frame.origin.y + photoImageView.frame.size.height - 20.0, width: photoImageView.frame.size.width, height: 20.0), selectedImageName: "blueStar.png", unSelectedImage: "grayStar.png", minValue: 0, maxValue: 5, intervalValue: 0.5, stepByStep: false)
        ratingView.userInteractionEnabled = false
        driverContainerView.addSubview(ratingView)
        
        /////////////////////////////////////////////////////////////////////
        //Create "No hay mensajero asignado aún" label
        noDriverLabel = UILabel(frame: CGRect(x: 35.0, y: 20.0, width: view.bounds.size.width - 100.0, height: driverInfoTopContainer.frame.size.height - 40.0))
        noDriverLabel.text = "NO HAY MENSAJERO ASIGNADO A TU SERVICIO AÚN"
        noDriverLabel.font = UIFont.boldSystemFontOfSize(15.0)
        noDriverLabel.numberOfLines = 0
        noDriverLabel.textAlignment = .Center
        noDriverLabel.textColor = UIColor.lightGrayColor()
        driverInfoTopContainer.addSubview(noDriverLabel)
    }
    
    //MARK: Actions
    
    @IBAction func updateDeliveryItem(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        Alamofire.manager.request(.GET, "\(Alamofire.getDeliveryItemServiceURL)/\(deliveryItem.identifier)").responseJSON { (request, response, json, error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            if error != nil {
                
            } else {
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    self.deliveryItem = DeliveryItem(deliveryItemJSON: JSON(jsonResponse["response"].object))
                    self.fillUIWithDeliveryItemInfo()
                } else {
                    
                }
            }
        }
    }
    
    @IBAction func backToHomePressed() {
        UIAlertView(title: "", message: "Puedes acceder a la información del servicio que acabas de pedir desde el menu 'Mis Servicios'", delegate: nil, cancelButtonTitle: "Ok").show()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func cellphoneButtonPressed() {
        //Show an alert to choose between calling the messenger or send a message
        UIAlertView(title: "", message: "¿Que deseas hacer?", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Llamar al mensajero", "Enviar mensaje de texto").show()
    }
    
    @IBAction func cancelServicePressed() {
        cancelServiceInServer()
    }
    
    //MARK: Server Stuff
    
    func cancelServiceInServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        Alamofire.manager.request(.DELETE, "\(Alamofire.cancelRequestServiceURL)/\(deliveryItem.identifier)/\(User.sharedInstance.identifier)").responseJSON { (request, response, json, error) -> Void in
            
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
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    println("Respuesta false del cancel service: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al cancelar el servicio. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
            
        }
    }
}

extension ServiceAcceptedViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        println(buttonIndex)
        if buttonIndex == 1 {
            //Call the messenger
            let cellPhone = deliveryItem.messengerInfo?.mobilePhone
            let url = NSURL(string: "tel://\(cellPhone!)")
            if let theURL = url {
                UIApplication.sharedApplication().openURL(theURL)
            } else {
                println("La url está en nillllll")
            }
        
        } else if buttonIndex == 2 {
            //Send SMS
            let messageVC = MFMessageComposeViewController()
            let cellPhone = deliveryItem.messengerInfo?.mobilePhone
            messageVC.recipients = [cellPhone!]
            messageVC.messageComposeDelegate = self
            presentViewController(messageVC, animated: true, completion: nil)
        }
    }
}

extension ServiceAcceptedViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
            case MessageComposeResultCancelled.value:
                println("El mensaje se cancelo")
                dismissViewControllerAnimated(true, completion: nil)
            
            case MessageComposeResultFailed.value:
                println("el mensaje falló")
                dismissViewControllerAnimated(true, completion: nil)
            
            case MessageComposeResultSent.value:
                println("el mensaje se envió")
                dismissViewControllerAnimated(true, completion: nil)
            
            default:
                break;
        }
    }
}
