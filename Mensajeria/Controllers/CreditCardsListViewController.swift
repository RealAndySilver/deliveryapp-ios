//
//  CreditCardsListViewController.swift
//  Mensajeria
//
//  Created by Diego Vidal on 16/03/16.
//  Copyright © 2016 iAm Studio. All rights reserved.
//

import UIKit

class CreditCardsListViewController: UIViewController {

    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var creditCards: [CreditCard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reveal button
        if revealViewController() != nil {
            revealButtonItem.target = revealViewController()
            revealButtonItem.action = "revealToggle:"
        }
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 100.0))
        tableView.backgroundColor = UIColor.whiteColor()
        
        let addCardButton = ShadowedButton(frame: CGRect(x: 20.0, y: 20.0, width: UIScreen.mainScreen().bounds.size.width - 40.0, height: 40.0))
        addCardButton.setTitle("Agregar Tarjeta", forState: .Normal)
        addCardButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13.0)
        addCardButton.backgroundColor = UIColor.getSecondaryAppColor()
        addCardButton.addTarget(self, action: "addTargetButtonPressed", forControlEvents: .TouchUpInside)
        tableView.tableFooterView!.addSubview(addCardButton)
        
        getPaymentMethodsFromServer()
    }
    
    ///////////////////////////////////
    //MARK: Server Stuff
    
    func getPaymentMethodsFromServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        let mutableURLRequest = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.getPaymentMethods)/\(User.sharedInstance.identifier)", methodType: "GET")
        
        if mutableURLRequest == nil {
            print("Error creando el request, está en nil")
            return
        }
        
        Alamofire.manager.request(mutableURLRequest!).responseJSON { response in
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            switch response.result {
            case .Success(let value):
                let jsonResponse = JSON(value)
                print("\(self.dynamicType) : Successfull response of the get payments: \(jsonResponse)")
                if jsonResponse["status"].boolValue == true {
                    if let unparsedCardsArray = jsonResponse["response"].object as? [[String: AnyObject]] {
                        self.creditCards = unparsedCardsArray.map {
                            return CreditCard(creditCardJson: JSON($0))
                        }
                        self.tableView.reloadData()
                    }
                }
                
            case .Failure(let error):
                print("\(self.dynamicType) : Error in the get payments: \(error.localizedDescription)")
            }
        }
    }
    
    ////////////////////////////////////
    //MARK: Actions 
    
    func addTargetButtonPressed() {
        let creditCardInfoVC = storyboard?.instantiateViewControllerWithIdentifier("CreditCardInfo") as! CreditCardInfoViewController
        creditCardInfoVC.delegate = self
        navigationController?.pushViewController(creditCardInfoVC, animated: true)
    }
}

//////////////////////////////////////////////////////////////

extension CreditCardsListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CreditCardCell", forIndexPath: indexPath) as! CreditCardTableViewCell
        cell.numberLabel.text = "**** \(creditCards[indexPath.row].lastFourNumbers)"
        if let creditCardId = CreditCardIdentifier(rawValue: creditCards[indexPath.row].franchise) {
            cell.creditCardImageView.image = UIImage(creditCardIdentifier: creditCardId)
        } else {
            cell.creditCardImageView.image = nil
        }
        return cell
    }
}

extension CreditCardsListViewController: CreditCardInfoViewControllerDelegate {
    func creditCardCreated(creditCard: CreditCard) {
        creditCards.append(creditCard)
        self.tableView.reloadData()
    }
}
