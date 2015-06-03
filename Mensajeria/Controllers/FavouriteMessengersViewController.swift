//
//  FavouriteMessengersViewController.swift
//  Mensajeria
//
//  Created by Developer on 25/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class FavouriteMessengersViewController: UIViewController {

    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var theTableView: UITableView!
    var favoritesMessengers = [MessengerInfo]()
    var selectedMessenger = 0

    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getFavoriteMessengers()
    }
    
    func setupUI() {
        theTableView.tableFooterView = UIView(frame: CGRectZero)
        theTableView.rowHeight = 144.0
        
        //Reveal button
        if revealViewController() != nil {
            revealButtonItem.target = revealViewController()
            revealButtonItem.action = "revealToggle:"
        }
    }
    
    //MARK: Server Stuff
    
    func removeMessengerAtIndex(index: Int) {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        Alamofire.manager.request(.PUT, "\(Alamofire.removeFavoriteServiceURL)/\(User.sharedInstance.identifier)", parameters: ["messenger_id" : favoritesMessengers[index].identifier], encoding: .URL).responseJSON { (request, response, json, error) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            if error != nil {
                println("Error en el unfav: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error al remover este mensajero de tus favoritos. Por favor revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Respuesta true del unfav: \(jsonResponse)")
                    let messengersArray = jsonResponse["response"].object as! [[String : AnyObject]]
                    self.favoritesMessengers = MessengerInfo.getMessengersObjectsFromArray(messengersArray)
                    self.theTableView.reloadData()
                    
                    
                } else {
                    println("Respuesta false del unfav: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al remover este mensajero de tus favoritos. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    func getFavoriteMessengers() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        Alamofire.manager.request(.GET, "\(Alamofire.getFavoritesServiceURL)/\(User.sharedInstance.identifier)").responseJSON { (request, response, json, error) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            if error != nil {
                println("Error en el get favorites: \(error?.localizedDescription)")
                UIAlertView(title: "Oops!", message: "Ocurrió un error. Revisa que estés conectado a internet e intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                let jsonResponse = JSON(json!)
                if jsonResponse["status"].boolValue {
                    println("Resputa true del get favorites: \(jsonResponse)")
                    let messengersArray = jsonResponse["response"].object as! [[String : AnyObject]]
                    self.favoritesMessengers = MessengerInfo.getMessengersObjectsFromArray(messengersArray)
                    self.theTableView.reloadData()
                    
                } else {
                    println("respuesta false del get favorites: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error accediendo a tus favoritos. Por favor intenta de nuevo", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
}

//MARK: UITableViewDataSource

extension FavouriteMessengersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            removeMessengerAtIndex(indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesMessengers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavMessengerCell") as! FavouriteMessengerCell
        cell.messengerName.text = "\(favoritesMessengers[indexPath.row].name) \(favoritesMessengers[indexPath.row].lastName)"
        cell.messengerPlate.text = favoritesMessengers[indexPath.row].plate
        return cell
    }
}

//MARK: UITableViewDelegate

extension FavouriteMessengersViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedMessenger = indexPath.row
        UIAlertView(title: "", message: "¿Que deseas hacer?", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Pedir Servicio", "Eliminar de favoritos").show()
    }
}

//MARK: UIAlertViewDelegate

extension FavouriteMessengersViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //Messenger selected alert
        println("button: \(buttonIndex)")
        if buttonIndex == 1 {
            //Request service
            
        } else if buttonIndex == 2 {
            //Remove messenger
            removeMessengerAtIndex(selectedMessenger)
        }
    }
}
