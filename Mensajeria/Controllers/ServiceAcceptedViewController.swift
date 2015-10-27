//
//  ServiceAcceptedViewController.swift
//  Mensajeria
//
//  Created by Developer on 9/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit
import MessageUI

protocol ServiceAcceptedDelegate: class {
    func serviceUpdated()
}

class ServiceAcceptedViewController: UIViewController {
    @IBOutlet weak var driverInfoTopContainer: ShadowedView!

    //Public Interface
    @IBOutlet weak var collectionView: UICollectionView!
    var deliveryItem: DeliveryItem!
    var presentedFromFindingServiceVC: Bool!
    var presentedFromPushNotification: Bool!
    var presentedFromFinishedServicesVC: Bool!
    var presentedFromAbortedService: Bool?
    var viewAppearedForTheFirstTime = true
    
    //////////////////////////////////////////////////////
    weak var delegate: ServiceAcceptedDelegate?
    var loadingView = MONActivityIndicatorView()
    //let zoomTransitioningDelegate = ZoomTransitionDelegate()
    //let zoomAnimationController = ZoomFromCellAnimator()
    //var frameToOpenDetailFrom: CGRect!
    
    var noDriverLabel: UILabel!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var updateButtonItem: UIBarButtonItem!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceStatusLabel: UILabel!
    @IBOutlet weak var driverContainerView: UIView!
    @IBOutlet weak var cancelServiceButton: UIButton!
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
    
    //MARK: View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presentedFromFindingServiceVC == true {
            navigationItem.hidesBackButton = true
            backToHomeButton.hidden = false
        } else if presentedFromFinishedServicesVC == true {
            backToHomeButton.hidden = true
            navigationItem.hidesBackButton = false
        } else if presentedFromPushNotification == true {
            backToHomeButton.hidden = true
            navigationItem.hidesBackButton = false
            
            //Create a dismiss bar button item
            let dismissBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "dismissVC")
            navigationItem.leftBarButtonItem = dismissBarButtonItem
        
        } else if let abortedService = presentedFromAbortedService {
            if abortedService == true {
                serviceStatusLabel.text = "CANCELADO"
                navigationItem.rightBarButtonItem = nil
                backToHomeButton.hidden = false
                backToHomeButton.setTitle("Reactivar servicio", forState: .Normal)
            }
        
        } else {
            backToHomeButton.hidden = true
        }
        
        if presentedFromFinishedServicesVC == true {
            cancelServiceButton.hidden = true
        }
        print("El delivery item: \(deliveryItem.deliveryItemDescription)")
        setupUI()
        fillUIWithDeliveryItemInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.currentServiceDetailScreenDeliveryItemID = deliveryItem.identifier
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceUpdatedNotificationReceived", name: "ServiceUpdatedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActiveReceived", name: "AppDidBecomeActiveNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*if viewAppearedForTheFirstTime {
            if deliveryItem.rated == false && deliveryItem.overallStatus == "finished" {
                let alert = UIAlertView(title: "", message: "Tu servicio se completó de forma exitosa. Por favor califica al mensajero encargado del servicio", delegate: self, cancelButtonTitle: "Ok")
                alert.tag = 3
                alert.show()
            }
            viewAppearedForTheFirstTime = false
        }*/
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.currentServiceDetailScreenDeliveryItemID = ""
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        print("me cerreeeeee")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: Custom Initialization Stuff
    
    func fillUIWithDeliveryItemInfo() {
        ////////////////////////////////////////////////////////////////////////
        //Set service info in the UI
        serviceNameLabel.text = deliveryItem.name
        pickupLabel.text = deliveryItem.pickupObject.address
        deliveryLabel.text = deliveryItem.deliveryObject.address
        if deliveryItem.timeToDeliver == "now" {
            shipmentDayLabel.text = "Inmediato"
        } else {
            shipmentDayLabel.text = "Durante el día"
        }
        costLabel.text = "$\(deliveryItem.declaredValue)"
        if let theMessengerInfo = deliveryItem.messengerInfo {
            nameLabel.text = "\(theMessengerInfo.name) \(theMessengerInfo.lastName)"
            photoImageView.sd_setImageWithURL(NSURL(string: theMessengerInfo.profilePicString), placeholderImage: UIImage(named: "ProfilePlaceholder"))
        }
        if let theCellPhone = deliveryItem.messengerInfo?.mobilePhone {
            cellphoneButton.setTitle("Celular: \(theCellPhone)", forState: .Normal)
        }
        platesLabel.text = deliveryItem.messengerInfo?.plate
        
        if presentedFromAbortedService == nil {
            switch deliveryItem.status {
            case "available":
                serviceStatusLabel.text = "BUSCANDO MENSAJERO"
            case "accepted":
                serviceStatusLabel.text = "ACEPTADO"
            case "in-transit":
                serviceStatusLabel.text = "EN CAMINO"
                cancelServiceButton.hidden = true
            case "returning":
                serviceStatusLabel.text = "REGRESANDO"
                cancelServiceButton.hidden = true
            case "returned":
                serviceStatusLabel.text = "SERVICIO FINALIZADO"
                cancelServiceButton.hidden = true
            case "delivered":
                serviceStatusLabel.text = "SERVICIO FINALIZADO"
                cancelServiceButton.hidden = true
            default:
                break
            }
        }
    
        if deliveryItem.overallStatus == "requested" {
            driverContainerView.hidden = true
            noDriverLabel.hidden = false
            loadingView.hidden = false
            loadingView.startAnimating()
            
        } else {
            driverContainerView.hidden = false
            noDriverLabel.hidden = true
            loadingView.hidden = true
            loadingView.stopAnimating()
        }
        
        //ETA Label 
        if let timeToArrival = deliveryItem.timeToMessengerArrival {
            etaLabel.text = "<\(timeToArrival)min"
        } else {
            etaLabel.text = ""
        }
        
        if deliveryItem.serviceImages.count > 0 {
            noPhotosLabel.hidden = true
        } else {
            noPhotosLabel.hidden = false
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
        /*let ratingView = RatingView(frame: CGRect(x: photoImageView.frame.origin.x + photoImageView.frame.size.width + 10.0, y: photoImageView.frame.origin.y + photoImageView.frame.size.height - 20.0, width: photoImageView.frame.size.width, height: 20.0), selectedImageName: "blueStar.png", unSelectedImage: "grayStar.png", minValue: 0, maxValue: 5, intervalValue: 0.5, stepByStep: false)
        ratingView.userInteractionEnabled = false
        driverContainerView.addSubview(ratingView)*/
        
        /////////////////////////////////////////////////////////////////////
        //Create "No hay mensajero asignado aún" label
        noDriverLabel = UILabel(frame: CGRect(x: 35.0, y: 0.0, width: view.bounds.size.width - 100.0, height: driverInfoTopContainer.frame.size.height - 40.0))
        noDriverLabel.text = "BUSCANDO MENSAJERO"
        noDriverLabel.font = UIFont.boldSystemFontOfSize(15.0)
        noDriverLabel.numberOfLines = 0
        noDriverLabel.textAlignment = .Center
        noDriverLabel.textColor = UIColor.lightGrayColor()
        driverInfoTopContainer.addSubview(noDriverLabel)
        
        //Setup searching indicator view
        loadingView.delegate = self
        driverInfoTopContainer.addSubview(loadingView)
        loadingView.center = CGPoint(x: noDriverLabel.center.x, y: noDriverLabel.center.y + 30.0)
        
        print("Minutes to arrivallllll: \(deliveryItem.timeToMessengerArrival)")
    }
    
    //MARK: Actions
    func dismissVC() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addToFavoritesPressed() {
        favouriteMessengerInServer()
    }
    
    @IBAction func updateDeliveryButtonPressed(sender: AnyObject) {
        updateDeliveryItem()
    }
    
    @IBAction func updateDeliveryItem() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.getDeliveryItemServiceURL)/\(deliveryItem.identifier)", methodType: "GET")
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            
            if case .Failure = response.result {
                
            } else {
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    //Call our delegate
                    print("Status updated: \(jsonResponse)")
                    self.delegate?.serviceUpdated()
                    
                    self.deliveryItem = DeliveryItem(deliveryItemJSON: JSON(jsonResponse["response"].object))
                    self.collectionView.reloadData()
                    self.fillUIWithDeliveryItemInfo()
                    if self.deliveryItem.overallStatus == "finished" {
                        let serviceFinishedAlert = UIAlertView(title: "Servicio Completado", message: "Tu servicio se ha realizado de forma exitosa. Puedes acceder a todos tus servicios finalizados desde el menú 'Servicios Terminados'", delegate: self, cancelButtonTitle: "Ok!")
                        serviceFinishedAlert.tag = 2
                        serviceFinishedAlert.show()
                    
                    } else if self.deliveryItem.overallStatus == "aborted" {
                        let abortedMessage: String
                        if let abortReason = jsonResponse["response"]["abort_reason"].string {
                            abortedMessage = "El mensajero ha abortado el servicio. Razón: \(abortReason). Puedes acceder a los servicios abortados desde el menú 'Abortados por Mensajero'"
                        } else {
                            abortedMessage = "El mensajero ha abortado el servicio. Ponte en contacto con el para definir el estado de tu servicio. Puedes acceder a los servicios abortados desde el menú 'Abortados por Mensajero'"
                        }
                        let serviceAbortedAlert = UIAlertView(title: "Servicio Abortado", message: abortedMessage, delegate: self, cancelButtonTitle: "Ok")
                        serviceAbortedAlert.tag = 4
                        serviceAbortedAlert.show()
                    }
                    
                } else {
                    
                }
            }
        }
    }
    
    @IBAction func backToHomePressed() {
        if let abortedService = presentedFromAbortedService {
            if abortedService == true {
                //Use this button to reactivate the service
                enableService()
            }
            return
        }
        UIAlertView(title: "", message: "Puedes acceder a la información del servicio que acabas de pedir desde el menu 'Mis Servicios'", delegate: nil, cancelButtonTitle: "Ok").show()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func cellphoneButtonPressed() {
        //Show an alert to choose between calling the messenger or send a message
        let callMessengerAlert = UIAlertView(title: "", message: "¿Que deseas hacer?", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Llamar al mensajero", "Enviar mensaje de texto")
        callMessengerAlert.tag = 1
        callMessengerAlert.show()
    }
    
    @IBAction func cancelServicePressed() {
        cancelServiceInServer()
    }
    
    //MARK: Navigation
    
    func goToRateMessengerVC() {
        let rateMessengerVC = storyboard?.instantiateViewControllerWithIdentifier("RateDriver") as! RateDriverViewController
        rateMessengerVC.messenger = deliveryItem.messengerInfo!
        rateMessengerVC.deliveryItemID = deliveryItem.identifier
        navigationController?.pushViewController(rateMessengerVC, animated: true)
    }
    
    //MARK: Server Stuff
    
    func enableService() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.restartItemServiceURL)/\(deliveryItem.identifier)", methodType: "PUT", theParameters: ["user_id" : User.sharedInstance.identifier])
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            
            if case .Failure(let error) = response.result{
                //Error
                print("Error en el restart service: \(error.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar habilitar de nuevo el servicio. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Success
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    UIAlertView(title: "", message: "El servicio se ha habilitado de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                    self.delegate?.serviceUpdated()
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    print("Respuesta false del restart item: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar habilitar de nuevo el servicio.", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    func favouriteMessengerInServer() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.addToFavouritesServiceURL)/\(User.sharedInstance.identifier)", methodType: "PUT", theParameters: ["messenger_id" : deliveryItem.messengerInfo!.identifier])
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            if case .Failure(let error) = response.result {
                print("hubo un error en el agregar a favoritos: \(error.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error. Revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    //Success
                    print("Resputa true del agregar a favoritos: \(jsonResponse)")
                    UIAlertView(title: "", message: "Se ha agregado este mensajero a tus favoritos!", delegate: nil, cancelButtonTitle: "Ok").show()
                    
                } else {
                    print("Respuesta false del agregar a favoritos: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al agregar este mensajero a tus favoritos. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    func cancelServiceInServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.cancelRequestServiceURL)/\(deliveryItem.identifier)/\(User.sharedInstance.identifier)", methodType: "DELETE")
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (response) -> Void in
            
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
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    self.delegate?.serviceUpdated()
                    
                } else {
                    print("Respuesta false del cancel service: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al cancelar el servicio. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    //MARK: Notification handlers 
    
    func serviceUpdatedNotificationReceived() {
        updateDeliveryItem()
    }
    
    func appDidBecomeActiveReceived() {
        updateDeliveryItem()
    }
}

//MARK: UICollectionViewDataSource

extension ServiceAcceptedViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deliveryItem.serviceImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ServiceImageCell", forIndexPath: indexPath) as! ServiceImageCell
        print("url de la imagennnn: \(deliveryItem.serviceImages[indexPath.item].urlString)")
        cell.serviceImageView.sd_setImageWithURL(NSURL(string: deliveryItem.serviceImages[indexPath.item].urlString))
        return cell
    }
}

//MARK: UICollectionViewDelegate

extension ServiceAcceptedViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! ServiceImageCell
        if let cellImage = selectedCell.serviceImageView.image {
            let imageVC = storyboard?.instantiateViewControllerWithIdentifier("Image") as! ImageViewController
            imageVC.galleryImage = cellImage
            
            //let attributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
            //let attributesFrame = attributes?.frame
            //frameToOpenDetailFrom = collectionView.convertRect(attributesFrame!, toView: view)
            /*zoomTransitioningDelegate.openingFrame = frameToOpenFrom
            
            imageVC.transitioningDelegate = zoomTransitioningDelegate
            mageVC.modalPresentationStyle = .Custom
            presentViewController(imageVC, animated: true, completion: nil)*/
            navigationController?.pushViewController(imageVC, animated: true)
        }
    }
}

//MARK: UIAlertViewDelegate

extension ServiceAcceptedViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 1 {
            //Call messenger tag
            print(buttonIndex)
            if buttonIndex == 1 {
                //Call the messenger
                let cellPhone = deliveryItem.messengerInfo?.mobilePhone
                let url = NSURL(string: "tel://\(cellPhone!)")
                if let theURL = url {
                    UIApplication.sharedApplication().openURL(theURL)
                } else {
                    print("La url está en nillllll")
                }
                
            } else if buttonIndex == 2 {
                //Send SMS
                let messageVC = MFMessageComposeViewController()
                let cellPhone = deliveryItem.messengerInfo?.mobilePhone
                messageVC.recipients = [cellPhone!]
                messageVC.messageComposeDelegate = self
                presentViewController(messageVC, animated: true, completion: nil)
            }
        
        } else if alertView.tag == 2 {
            //Service finished alert 
            if deliveryItem.rated == false {
                //If the service has not been rated, proceed to rate it
                goToRateMessengerVC()
            }
        
        } else if alertView.tag == 3 {
            goToRateMessengerVC()
        } else if alertView.tag == 4 {
            //Aborted alert
            if let navigationController = navigationController {
                navigationController.popViewControllerAnimated(true)
            } else {
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

//MARK: MFMessageComposeViewController

extension ServiceAcceptedViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
            case MessageComposeResultCancelled.rawValue:
                print("El mensaje se cancelo")
                dismissViewControllerAnimated(true, completion: nil)
            
            case MessageComposeResultFailed.rawValue:
                print("el mensaje falló")
                dismissViewControllerAnimated(true, completion: nil)
            
            case MessageComposeResultSent.rawValue:
                print("el mensaje se envió")
                dismissViewControllerAnimated(true, completion: nil)
            
            default:
                break;
        }
    }
}

//MARK: MONActivityViewDelegate

extension ServiceAcceptedViewController: MONActivityIndicatorViewDelegate {
    func activityIndicatorView(activityIndicatorView: MONActivityIndicatorView!, circleBackgroundColorAtIndex index: UInt) -> UIColor! {
        return UIColor.getSecondaryAppColor()
    }
}
