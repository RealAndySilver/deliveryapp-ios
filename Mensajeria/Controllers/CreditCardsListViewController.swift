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
    
    func deleteCardWithId(cardId: String) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.deleteCard)/\(cardId)", methodType: "DELETE")
        if request == nil {
            print("Nil request in the delete card method")
            return
        }
        
        Alamofire.manager.request(request!).responseJSON { response in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            switch response.result {
            case .Success(let value):
                let jsonResponse = JSON(value)
                print("Successfull response in the delete card: \(jsonResponse)")
                if jsonResponse["status"].boolValue == true {
                    //Remove card from the list 
                    let filteredCreditCards = self.creditCards.filter { $0.identifier != cardId }
                    self.creditCards.removeAll()
                    self.creditCards = filteredCreditCards
                    self.tableView.reloadData()
                
                } else {
                    let alert = UIAlertController(title: "Oops!", message: "Parece que hubo un error al eliminar tu tarjeta. Por favor intenta de nuevo", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            case .Failure(let error):
                print("Error in the delete card: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Oops!", message: "Hubo un error en la conexión. Por favor revisa que estés conectado a internet e intenta de nuevo", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
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

extension CreditCardsListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCreditCard = creditCards[indexPath.row]
        let alert = UIAlertController(title: "", message: "Que deseas hacer para la tarjeta terminada en \(selectedCreditCard.lastFourNumbers)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Eliminar", style: .Destructive, handler: { _ in
            self.deleteCardWithId(selectedCreditCard.identifier)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension CreditCardsListViewController: CreditCardInfoViewControllerDelegate {
    func creditCardCreated(creditCard: CreditCard) {
        creditCards.append(creditCard)
        self.tableView.reloadData()
    }
}
