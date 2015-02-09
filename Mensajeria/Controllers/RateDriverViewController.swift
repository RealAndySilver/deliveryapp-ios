//
//  RateDriverViewController.swift
//  Mensajeria
//
//  Created by Developer on 9/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class RateDriverViewController: UIViewController {
    
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var rateNumberLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var starsContainer: UIView!
    var rateView: RatingView!
    var firstTimeViewAppears = true

    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTimeViewAppears {
            rateView = RatingView(frame: CGRect(x: 10.0, y: 10.0, width: starsContainer.bounds.size.width - 20.0, height: 30.0), selectedImageName: "blueStar.png", unSelectedImage: "grayStar.png", minValue: 0, maxValue: 5, intervalValue: 0.5, stepByStep: true)
            starsContainer.addSubview(rateView)
            firstTimeViewAppears = false
        }
    }
    
    func setupUI() {
        commentsTextView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        commentsTextView.layer.borderWidth = 1.0
    }
    
    //MARK: Actions 
    
    @IBAction func rateButtonPressed() {
        
    }
}
