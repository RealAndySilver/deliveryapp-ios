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

    //Public Interface
    var deliveryItem: DeliveryItem!
    var presentedFromFindingServiceVC: Bool!
    
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
    
    //MARK: View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if presentedFromFindingServiceVC == true {
            navigationItem.hidesBackButton = true
        } else {
            navigationItem.hidesBackButton = false
        }
        println("El delivery item: \(deliveryItem.deliveryItemDescription)")
        setupUI()
    }
    
    //MARK: Custom Initialization Stuff
    
    func setupUI() {
        //Create RatingView
        let ratingView = RatingView(frame: CGRect(x: photoImageView.frame.origin.x, y: photoImageView.frame.origin.y + photoImageView.frame.size.height, width: photoImageView.frame.size.width, height: 20.0), selectedImageName: "blueStar.png", unSelectedImage: "grayStar.png", minValue: 0, maxValue: 5, intervalValue: 0.5, stepByStep: false)
        ratingView.userInteractionEnabled = false
        containerView.addSubview(ratingView)
        
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
    }
    
    //MARK: Actions
    @IBAction func backToHomePressed() {
        UIAlertView(title: "", message: "Puedes acceder a la información del servicio que acabas de pedir desde el menu 'Mis Servicios'", delegate: nil, cancelButtonTitle: "Ok").show()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func cellphoneButtonPressed() {
        //Show an alert to choose between calling the messenger or send a message
        UIAlertView(title: "", message: "¿Que deseas hacer?", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Llamar al mensajero", "Enviar mensaje de texto").show()
    }
    
    @IBAction func cancelServicePressed() {
        
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
