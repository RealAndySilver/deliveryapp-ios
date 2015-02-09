//
//  ServiceAcceptedViewController.swift
//  Mensajeria
//
//  Created by Developer on 9/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ServiceAcceptedViewController: UIViewController {

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
        setupUI()
    }
    
    //MARK: Custom Initialization Stuff
    
    func setupUI() {
        //Create RatingView
        let ratingView = RatingView(frame: CGRect(x: photoImageView.frame.origin.x, y: photoImageView.frame.origin.y + photoImageView.frame.size.height, width: photoImageView.frame.size.width, height: 20.0), selectedImageName: "blueStar.png", unSelectedImage: "grayStar.png", minValue: 0, maxValue: 5, intervalValue: 0.5, stepByStep: false)
        ratingView.userInteractionEnabled = false
        containerView.addSubview(ratingView)
    }
    
    //MARK: Actions
    
    @IBAction func mapButtonPressed() {
        
    }
    
    @IBAction func cellphoneButtonPressed() {
        
    }
    
    @IBAction func cancelServicePressed() {
        
    }
}
