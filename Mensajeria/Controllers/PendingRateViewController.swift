//
//  PendingRateViewController.swift
//  Mensajeria
//
//  Created by Developer on 4/09/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class PendingRateViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var commentTextView: DesignableTextView!
    @IBOutlet weak var messengerNameLabel: UILabel!
    @IBOutlet weak var rateMessengerView: DesignableView!
    
    var rateView: RatingView!
    var firstTimeViewAppears = true
    var messengerDic: [String : String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        messengerNameLabel.text = messengerDic["messengerName"]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTimeViewAppears {
            rateView = RatingView(frame: CGRect(x: 30.0, y: messengerNameLabel.frame.origin.y + messengerNameLabel.frame.size.height + 20.0, width: 200.0, height: 40.0), selectedImageName: "blueStar.png", unSelectedImage: "grayStar.png", minValue: 0, maxValue: 5, intervalValue: 0.5, stepByStep: false)
            rateView.value = 5.0
            rateMessengerView.addSubview(rateView)
            firstTimeViewAppears = false
        }
    }
    
    //MARK: Actions 
    
    @IBAction func tapGestureDetected(sender: AnyObject) {
        commentTextView.resignFirstResponder()
    }
    
    @IBAction func calificarButtonPressed() {
        sendMessengerRating()
    }
    
    //MARK: Server stuff
    
    func sendMessengerRating() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let deliveryItemId = messengerDic["deliveryItemId"]! as String
        let userID = messengerDic["userId"]! as String
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.rateMessengerServiceURL)/\(deliveryItemId)", methodType: "PUT", theParameters: ["user_id" : userID, "rating" : rateView.value, "review" : commentTextView.text])
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (request, response, json, error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error != nil {
                println("error en la peticion: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error el intentar calificar al mensajero. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Success
                NSUserDefaults.standardUserDefaults().removeObjectForKey("pendingRatingDicKey")
                
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Respuesta true del rate: \(jsonResponse)")
                    UIAlertView(title: "", message: "Mensajero calificado de forma exitosa!", delegate: nil, cancelButtonTitle: "Ok").show()
                } else {
                    println("respuesta false del rate: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un problema al calificar el mensajero. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}
