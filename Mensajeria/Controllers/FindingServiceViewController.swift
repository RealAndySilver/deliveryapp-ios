//
//  FindingServiceViewController.swift
//  Mensajeria
//
//  Created by Developer on 9/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class FindingServiceViewController: UIViewController {

    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }
    
    //MARK: Actions
    
    @IBAction func cancelServicePressed() {
        UIActionSheet(title: "¿Estás seguro de cancelar el servicio?", delegate: self, cancelButtonTitle: "Volver", destructiveButtonTitle: "Cancelar el servicio").showInView(view)
    }
}

extension FindingServiceViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            //Cancel Service
            navigationController?.popViewControllerAnimated(true)
        }
    }
}
