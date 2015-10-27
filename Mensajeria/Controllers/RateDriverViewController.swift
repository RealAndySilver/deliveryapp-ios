//
//  RateDriverViewController.swift
//  Mensajeria
//
//  Created by Developer on 9/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class RateDriverViewController: UIViewController {
    
    //Public Interace
    var messenger: MessengerInfo!
    var deliveryItemID: String!
    
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var rateNumberLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var starsContainer: UIView!
    var rateView: RatingView!
    var firstTimeViewAppears = true

    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupUI()
        
        //Save messenger info in UserDefaults, this is in case the user quits the app in this screen and don't rate the messenger, so the next time the user opens the app a popup will appear to rate the messenger
        let pendingRatingDic = ["messengerName" : "\(messenger.name) \(messenger.lastName)", "deliveryItemId" : deliveryItemID, "userId" : User.sharedInstance.identifier]
        NSUserDefaults.standardUserDefaults().setObject(pendingRatingDic, forKey: "pendingRatingDicKey")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTimeViewAppears {
            rateView = RatingView(frame: CGRect(x: 30.0, y: 10.0, width: 200.0, height: 40.0), selectedImageName: "blueStar.png", unSelectedImage: "grayStar.png", minValue: 0, maxValue: 5, intervalValue: 0.5, stepByStep: false)
            rateView.delegate = self
            rateView.value = 5.0
            starsContainer.addSubview(rateView)
            firstTimeViewAppears = false
        }
    }
    
    func setupUI() {
        driverNameLabel.text = "\(messenger.name) \(messenger.lastName)"
        
        commentsTextView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        commentsTextView.layer.borderWidth = 1.0
    }
    
    //MARK: Actions 
    
    @IBAction func tapDetected(sender: AnyObject) {
        commentsTextView.resignFirstResponder()
    }

    @IBAction func rateButtonPressed() {
        //UIAlertView(title: "", message: "Mensajero calificado de forma exitosa!", delegate: nil, cancelButtonTitle: "Ok").show()
        //navigationController?.popToRootViewControllerAnimated(true)
        sendMessengerRating()
    }
    
    //MARK: Server stuff

    func sendMessengerRating() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.rateMessengerServiceURL)/\(deliveryItemID)", methodType: "PUT", theParameters: ["user_id" : User.sharedInstance.identifier, "rating" : rateView.value, "review" : commentsTextView.text])
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (response) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            if case .Failure(let error) = response.result {
                print("error en la peticion: \(error.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error el intentar calificar al mensajero. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Success
                NSUserDefaults.standardUserDefaults().removeObjectForKey("pendingRatingDicKey")

                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    print("Respuesta true del rate: \(jsonResponse)")
                    UIAlertView(title: "", message: "Mensajero calificado de forma exitosa!", delegate: nil, cancelButtonTitle: "Ok").show()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    print("respuesta false del rate: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un problema al calificar el mensajero. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
}

//MARK: RatingViewDelegate

extension RateDriverViewController: RatingViewDelegate {
    func rateChanged(sender: RatingView!) {
        rateNumberLabel.text = "\(sender.value)"
    }
}

//MARK: UITextviewDelegate

extension RateDriverViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
