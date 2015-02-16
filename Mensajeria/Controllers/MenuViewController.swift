//
//  MenuViewController.swift
//  Mensajeria
//
//  Created by Developer on 13/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
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
    let menuArray = ["Solicitar Servicio", "Mis Servicios Activos", "Mi Perfil", "Mis Favoritos", "Historial de Servicios", "Términos y Condiciones", "Cerrar Sesión"]
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        println("selected menu: \(selectedMenu)")
    }
    
    func setupUI() {
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
}

//MARK: UITableViewDataSource

extension MenuViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as UITableViewCell
        cell.textLabel?.text = menuArray[indexPath.row]
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == selectedMenu {
            println("aqui estoy")
            //The selected option was the current screen, so don't replace the front view controller
            revealViewController().setFrontViewPosition(FrontViewPosition.Left, animated: true)
        
        } else {
            selectedMenu = indexPath.row
            if indexPath.row == SelectedMenuOption.SolicitarOption.rawValue {
                //Go to "Solicitar Servicio"
                let requestNavController = storyboard?.instantiateViewControllerWithIdentifier("MainNavController") as UINavigationController
                revealViewController().pushFrontViewController(requestNavController, animated: true)
            }
            
            else if indexPath.row == SelectedMenuOption.MiPerfilOption.rawValue {
                //Go to "Mi Perfil"
                let myProfileNavController = storyboard?.instantiateViewControllerWithIdentifier("MyProfileNavController") as UINavigationController
                revealViewController().pushFrontViewController(myProfileNavController, animated: true)
            
            } else if indexPath.row == SelectedMenuOption.CerrarSesionOption.rawValue {
                //Close session
                revealViewController().dismissViewControllerAnimated(true, completion: nil)
            
            } else if indexPath.row == SelectedMenuOption.MisServiciosOption.rawValue {
                //Go to "Mis Servicios"
                let activeServicesNavController = storyboard?.instantiateViewControllerWithIdentifier("ActiveServicesNavController") as UINavigationController
                revealViewController().pushFrontViewController(activeServicesNavController, animated: true)
            
            } else if indexPath.row == SelectedMenuOption.HistorialDeServiciosOptions.rawValue {
                let finishedServicesNavController = storyboard?.instantiateViewControllerWithIdentifier("FinishedServicesNavController") as UINavigationController
                revealViewController().pushFrontViewController(finishedServicesNavController, animated: true)
            }
        }
    }
}
