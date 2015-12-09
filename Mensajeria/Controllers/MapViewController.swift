//
//  MapViewController.swift
//  Mensajeria
//
//  Created by Diego Fernando Vidal Illera on 2/5/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    //Public Interface
    var locationDic: NSDictionary?
    var wasSelectingPickupLocation: Bool!
    var onAddressAvailable: ((theAddress: String, locationCoordinates: CLLocationCoordinate2D, selectingPickupLocation: Bool) -> ())?
    
    //Private Interface
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressTextfield: UITextField!
    private let locationManager = CLLocationManager()
    private var currentLocationCoordinate: CLLocationCoordinate2D!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: Map Stuff
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        currentLocationCoordinate = coordinate
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            if let address = response?.firstResult() {
                if address.lines != nil {
                    let lines = address.lines as! [String]
                    let fullAddress = lines.joinWithSeparator(" - ")
                    let addressComponents = fullAddress.componentsSeparatedByString(" a ")
                    if let streetName = addressComponents.first {
                        self.addressTextfield.text = "\(streetName)"
                    }
                    //self.addressTextfield.text = join("-", lines)
                }
            }
        }
    }
    
    //MARK: Actions 
    
    @IBAction func recentLocationsButtonPressed() {
        let addressHistoryVC = storyboard!.instantiateViewControllerWithIdentifier("AddressHistory") as! AddressHistoryViewController
        addressHistoryVC.delegate = self
        navigationController!.pushViewController(addressHistoryVC, animated: true)
    }
    
    @IBAction func locationChoosed(sender: AnyObject) {
        sendAddressToPreviousVC(addressTextfield.text!, location: currentLocationCoordinate, selectingPickupLocation: wasSelectingPickupLocation)
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK: Custom Stuff
    
    func sendAddressToPreviousVC(address: String, location: CLLocationCoordinate2D, selectingPickupLocation: Bool) {
        //Implement the closure to send the address back to the previous VC
        self.onAddressAvailable?(theAddress: address, locationCoordinates: location, selectingPickupLocation: selectingPickupLocation)
    }
    
    //MARK: Navigation 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let visibleRegion = mapView.projection.visibleRegion()
        let regionBounds = GMSCoordinateBounds(region: visibleRegion)
        let northEast = regionBounds.northEast
        let southWeast = regionBounds.southWest
        print("\(northEast.latitude) - \(northEast.longitude), \(southWeast.latitude), \(southWeast.longitude)")
        
        if segue.identifier == "ToSearchAddressSegue" {
            let searchAddressVC = segue.destinationViewController as! SearchAddressViewController
            searchAddressVC.address = addressTextfield.text
            searchAddressVC.delegate = self
        }
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
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first  {
            if let locationDic = locationDic {
                mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: locationDic["lat"] as! CLLocationDegrees, longitude: locationDic["lon"] as! CLLocationDegrees), zoom: 15, bearing: 0, viewingAngle: 0)
            } else {
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            }
            locationManager.stopUpdatingLocation()
        }
    }
}

//MARK: AddressHistoryViewControllerDelegate

extension MapViewController: AddressHistoryDelegate {
    func addressSelected(adressDic: [String : AnyObject], forPickupLocation: Bool) {
        /*if forPickupLocation {
            pickupLocationDic = adressDic
            pickupAddressTextfield.text = pickupLocationDic["address"] as? String
        } else {
            destinationLocationDic = adressDic
            finalAddressTextfield.text = destinationLocationDic["address"] as? String
        }
        getServicePrice()*/
    }
}

//MARK: GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
}

//MARK: SearchAddressViewControllerDelegate 

extension MapViewController: SearchAddressViewControllerDelegate {
    func addressSelectedWithName(name: String, coordinates: CLLocationCoordinate2D) {
        print("me llego el delegateeeee")
        addressTextfield.text = name
        currentLocationCoordinate = coordinates
        let cameraPosition = GMSCameraPosition(target: currentLocationCoordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.camera = cameraPosition
    }
}
