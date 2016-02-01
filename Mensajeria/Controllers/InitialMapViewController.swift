//
//  InitialMapViewController.swift
//  Mensajeria
//
//  Created by Developer on 10/11/15.
//  Copyright © 2015 iAm Studio. All rights reserved.
//

import UIKit

class InitialMapViewController: UIViewController {

    //Enums 
    enum PickupMoment: Int {
        case Now
        case Later
    }
    
    //Outlets
    @IBOutlet weak var deliveryMomentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pickupMomentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var requestServiceButton: ShadowedButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    
    //Variables
    let locationManager = CLLocationManager()
    var updateLocationsForTheFirstTime = false
    var locationsArray: [[String: Double]]?
    
    //////////////////////////////////////////////////////////
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Reveal button
        if revealViewController() != nil {
            revealButtonItem.target = revealViewController()
            revealButtonItem.action = "revealToggle:"
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        requestServiceButton.layer.cornerRadius = 15.0
    }
    
    //MARK: Actions 
    
    @IBAction func tapGestureDetected(sender: AnyObject) {
        performSegueWithIdentifier("ToRequestService", sender: nil)
    }
 
    //MARK: Server Stuff
    
    func getRandomLocationsFromServerBasedOnLocation(location: CLLocation) {
        Alamofire.manager.request(.GET, "\(Alamofire.closeToMeServiceUrl)/\(location.coordinate.latitude)/\(location.coordinate.longitude)").responseJSON { (response) -> Void in
            
            switch response.result {
            case .Success(let value):
                let jsonResponse = JSON(value)
                print("Succesfull response of the close to me: \(jsonResponse)")
                if jsonResponse["status"].boolValue {
                    if let locationsArray = jsonResponse["response"]["locations"].object as? [[String : Double]] {
                        self.drawRandomLocationsUsingArray(locationsArray)
                        self.locationsArray = locationsArray
                    }
                }
                
            case .Failure:
                print("Error in the close to me")
            }
        }
    }
    
    //MARK: Custom Stuff
    
    func drawRandomLocationsUsingArray(locationsArray: [[String : Double]]) {
        for i in 0..<locationsArray.count {
            guard let latitude = locationsArray[i]["lat"], let longitude = locationsArray[i]["lon"] else {
                print("Error en los valores de latitud y longitud")
                return
            }
            
            let randomLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            print("Random location: \(randomLocation)")
            
            let marker = GMSMarker(position: randomLocation)
            marker.icon = UIImage(named: "MotorcycleMarker")
            marker.map = mapView
        }
    }
    
    /*func generateRandomLocationsBasedOnCurrentLocation(location: CLLocation) {
        for _ in 0...10 {
            let randomLatitude = Double(-10672 + Double(Int(arc4random_uniform(10672*2)))) / Double(1_000_000)
            let randomLongitude = Double(-6824.0 + Double(Int(arc4random_uniform(6824*2)))) / Double(1_000_000)
            print("latitudeeee: \(randomLatitude)")
            
            let randomLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude + randomLatitude, longitude: location.coordinate.longitude + randomLongitude)
            print("Random location: \(randomLocation)")
            
            let marker = GMSMarker(position: randomLocation)
            marker.icon = UIImage(named: "MotorcycleMarker")
            marker.map = mapView
        }
    }*/
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToRequestService" {
            let requestServiceVC = segue.destinationViewController as! RequestServiceViewController
            switch pickupMomentSegmentedControl.selectedSegmentIndex {
            case PickupMoment.Now.rawValue:
                requestServiceVC.selectedPickupCase = ("now", "Inmediato")
            case PickupMoment.Later.rawValue:
                requestServiceVC.selectedPickupCase = ("later", "Durante el Día")
            default:
                requestServiceVC.selectedPickupCase = ("now", "Inmediato")
            }
            
            switch deliveryMomentSegmentedControl.selectedSegmentIndex {
            case PickupMoment.Now.rawValue:
                requestServiceVC.selectedDeliveryCase = ("now", "Inmediato")
            case PickupMoment.Later.rawValue:
                requestServiceVC.selectedDeliveryCase = ("later", "Durante el Día")
            default:
                requestServiceVC.selectedDeliveryCase = ("now", "Inmediato")
            }
            
            requestServiceVC.locationsToDraw = locationsArray
        }
    }
}

//MARK: CLLocationManagerDelegate

extension InitialMapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first  {
            if !updateLocationsForTheFirstTime {
                //generateRandomLocationsBasedOnCurrentLocation(location)
                getRandomLocationsFromServerBasedOnLocation(location)
            }
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            updateLocationsForTheFirstTime = true
        }
        locationManager.stopUpdatingLocation()
    }
}

//MARK: GMSMapViewDelegate

extension InitialMapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        print("position: \(position.target.latitude, position.target.longitude)")
    }
}

//MARK: UITextFieldDelegate

extension InitialMapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

