//
//  AbortedServicesViewController.swift
//  Mensajeria
//
//  Created by Developer on 20/03/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class AbortedServicesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var abortedServices = [DeliveryItem]()

    //MARK: Life cycle & Initialization stuff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getAbortedServices()
    }
    
    func setupUI() {
        tableView.rowHeight = 185.0
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    //MARK: Server stuff
    
    func getAbortedServices() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        Alamofire.manager.request(.GET, "\(Alamofire.abortedItemsServiceURL)/\(User.sharedInstance.identifier)").responseJSON { (request, response, json, error) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            if error != nil {
                //Error 
                println("Error obteniendo los aborted items: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al intentar acceder a tus servicios abortados. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Success
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Resputa true del aborted: \(jsonResponse)")
                    let tempDeliveryItems = jsonResponse["response"]
                    for i in 0..<tempDeliveryItems.count {
                        let deliveryItem = DeliveryItem(deliveryItemJSON: tempDeliveryItems[i])
                        self.abortedServices.append(deliveryItem)
                    }
                    self.tableView.reloadData()
                    
                } else {
                    println("Respuesta false del aborted: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al acceder a tus servicios abortados. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
}

//MARK: UITableViewDataSource

extension AbortedServicesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return abortedServices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AbortedServiceCell", forIndexPath: indexPath) as ActiveServiceCell
        return cell
    }
}
