//
//  MenuViewController.swift
//  Mensajeria
//
//  Created by Developer on 13/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var mensajeriaLabel: UILabel!
    
    enum SelectedMenuOption: Int {
        case SolicitarOption = 0,
        MisServiciosOption,
        MiPerfilOption,
        MisFavoritosOption,
        HistorialDeServiciosOptions,
        TermsAndConditionsOptions,
        CerrarSesionOption
    }

    @IBOutlet weak var tableView: UITableView!
    var selectedMenu = 0
    let menuArray = ["Solicitar Servicio", "Mis Servicios Activos", "Mi Perfil", "Mis Favoritos", "Servicios Terminados", "Términos y Condiciones", "Cerrar Sesión"]
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        println("selected menu: \(selectedMenu)")
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = 48.0
        
        mensajeriaLabel.layer.shadowColor = UIColor.blackColor().CGColor
        mensajeriaLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        mensajeriaLabel.layer.shadowOpacity = 0.2
        mensajeriaLabel.layer.shadowRadius = 1.0
        mensajeriaLabel.layer.shouldRasterize = true
        mensajeriaLabel.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
}

//MARK: UITableViewDataSource

extension MenuViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as MenuCell
        cell.menuItemLabel.text = menuArray[indexPath.row]
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == selectedMenu {
            println("aqui estoy")
            //The selected option was the current screen, so don't replace the front view controller
            revealViewController().setFrontViewPosition(FrontViewPosition.Left, animated: true)
        
        } else {
            if indexPath.row == SelectedMenuOption.SolicitarOption.rawValue {
                selectedMenu = indexPath.row
                //Go to "Solicitar Servicio"
                let requestNavController = storyboard?.instantiateViewControllerWithIdentifier("MainNavController") as UINavigationController
                revealViewController().pushFrontViewController(requestNavController, animated: true)
            }
            
            else if indexPath.row == SelectedMenuOption.MiPerfilOption.rawValue {
                selectedMenu = indexPath.row
                //Go to "Mi Perfil"
                let myProfileNavController = storyboard?.instantiateViewControllerWithIdentifier("MyProfileNavController") as UINavigationController
                revealViewController().pushFrontViewController(myProfileNavController, animated: true)
            
            } else if indexPath.row == SelectedMenuOption.CerrarSesionOption.rawValue {
                //Close session
                UIActionSheet(title: "¿Estás segur@ de cerrar sesión?", delegate: self, cancelButtonTitle: "Cancelar", destructiveButtonTitle: "Cerrar Sesión").showInView(view)
            
            } else if indexPath.row == SelectedMenuOption.MisServiciosOption.rawValue {
                selectedMenu = indexPath.row
                //Go to "Mis Servicios"
                let activeServicesNavController = storyboard?.instantiateViewControllerWithIdentifier("ActiveServicesNavController") as UINavigationController
                revealViewController().pushFrontViewController(activeServicesNavController, animated: true)
            
            } else if indexPath.row == SelectedMenuOption.HistorialDeServiciosOptions.rawValue {
                selectedMenu = indexPath.row
                let finishedServicesNavController = storyboard?.instantiateViewControllerWithIdentifier("FinishedServicesNavController") as UINavigationController
                revealViewController().pushFrontViewController(finishedServicesNavController, animated: true)
            }
        }
    }
}

//MARK: UIActionSheetDelegate

extension MenuViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            //Cerrar sesión alert 
            //Erase user object from NSUserDefaults
            NSUserDefaults.standardUserDefaults().removeObjectForKey("UserInfo")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            revealViewController().dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
