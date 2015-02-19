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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTimeViewAppears {
            rateView = RatingView(frame: CGRect(x: 30.0, y: 10.0, width: 200.0, height: 40.0), selectedImageName: "blueStar.png", unSelectedImage: "grayStar.png", minValue: 0, maxValue: 5, intervalValue: 0.5, stepByStep: false)
            rateView.delegate = self
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
    
    @IBAction func rateButtonPressed() {
        UIAlertView(title: "", message: "Mensajero calificado de forma exitosa!", delegate: nil, cancelButtonTitle: "Ok").show()
        navigationController?.popToRootViewControllerAnimated(true)
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
