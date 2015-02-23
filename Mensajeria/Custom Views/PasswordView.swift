//
//  PasswordView.swift
//  Mensajeria
//
//  Created by Developer on 23/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class PasswordView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var newPasswordTextfield: UITextField!
    let nibName = "PasswordView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: nibName, bundle: NSBundle.mainBundle())
        let view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        return view
    }
    
    @IBAction func acceptButtonPressed() {
        
    }
}

extension PasswordView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
