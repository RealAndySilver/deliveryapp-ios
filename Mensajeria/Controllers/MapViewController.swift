//
//  MapViewController.swift
//  Mensajeria
//
//  Created by Diego Fernando Vidal Illera on 2/5/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressTextfield: UITextField!
    let locationManager = CLLocationManager()
    var onAddressAvailable: ((theAddress: String) -> ())?
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        sendAddressToPreviousVC(addressTextfield.text)
    }
    
    //MARK: Map Stuff
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            if let address = response?.firstResult() {
                if address.lines != nil {
                    let lines = address.lines as [String]
                    self.addressTextfield.text = join("-", lines)
                }
            }
        }
    }
    
    //MARK: Custom Stuff
    
    func sendAddressToPreviousVC(address: String) {
        //Implement the closure to send the address back to the previous VC
        self.onAddressAvailable?(theAddress: address)
    }
}

//MARK: UITextfieldDelegate

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}

//MARK: GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
}