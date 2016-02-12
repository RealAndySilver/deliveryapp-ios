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
    @IBOutlet weak var confirmAddressTextfield: UITextField!
    @IBOutlet var alertConfirmView: UIView!
    @IBOutlet weak var addressTextFieldContainer: UIView!
    @IBOutlet weak var adressTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressTextfield: UITextField!
    private let locationManager = CLLocationManager()
    private var timer: NSTimer!
    private let kTimerWaitingTime = 3 //Seconds
    private var currentLocationCoordinate: CLLocationCoordinate2D!
    private let kCellId = "AddressCell"
    private var addressResults: [[String: AnyObject]] = []
    private let kNorthEastLatitude = 4.80140167730285
    private let kNorthEastLongitude = -74.0019284561276
    private let kSouthWeastLatitude = 4.50541610527197
    private let kSouthWeastLongitude = -74.206731878221
    private var selectedLocationFromResultsTableView = false
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Entré al mapaaaaa")
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        adressTableView.hidden = true
        adressTableView.tableFooterView = UIView(frame: CGRect.zero)
        view.addSubview(adressTableView)
        
        addressTextfield.tag = 1
        addressTextfield.addTarget(self, action: "addressDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adressTableView.frame = CGRect(x: 0.0, y: addressTextFieldContainer.frame.origin.y + addressTextFieldContainer.frame.size.height, width: view.bounds.size.width, height: 132.0)
    }
    
    //MARK: Map Stuff
    
    func searchAddressUsingGeocoding() {
        Alamofire.manager.request(.GET, "https://maps.googleapis.com/maps/api/geocode/json", parameters: ["address" : addressTextfield.text!, "region" : "co", "bounds" : "\(kSouthWeastLatitude),\(kSouthWeastLongitude)|\(kNorthEastLatitude),\(kNorthEastLongitude)"], encoding: ParameterEncoding.URL).responseJSON { (response) -> Void in
            
            self.activityIndicator.stopAnimating()
            if case .Failure(let error) = response.result {
                print("Hubo un error obteniendo las direcciones en Google: \(error.localizedDescription)")
            } else {
                let jsonResponse = JSON(response.result.value!)
                print("Respuesta correcta del get address: \(jsonResponse)")
                
                let statusString = jsonResponse["status"].stringValue
                let geocodingStatusCode = GeocodingStatusCode(rawValue: statusString)
                if let geocodingStatusCode = geocodingStatusCode {
                    switch geocodingStatusCode {
                    case .Ok:
                        print("Everything went ok")
                        self.addressResults = jsonResponse["results"].object as! [Dictionary<String , AnyObject>]
                        
                        /*if !self.addressResults.isEmpty {
                            //Add a harcoded result in the first position with the exact adress that the user wrote
                            var firstResultCopy = self.addressResults[0]
                            firstResultCopy["formatted_address"] = self.addressTextfield.text!
                            self.addressResults.insert(firstResultCopy, atIndex: 0)
                        }*/
                        
                        //self.adressTableView.hidden = false
                        self.animateAddressTableView(show: true)
                        self.adressTableView.reloadData()
                        
                    case .ZeroResults:
                        print("No results")
                        self.addressResults = []
                        //self.adressTableView.hidden = true
                        self.animateAddressTableView(show: false)
                        self.adressTableView.reloadData()
                        
                        let alert = UIAlertController(title: "Oops!", message: "No se encontró ninguna dirección con esa información, por favor intenta con otra dirección", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    default:
                        print("Hubo un error la petición al Geocoding")
                    }
                }
            }
        }
    }
    
    func animateAddressTableView(show show: Bool) {
        if show {
            if adressTableView.hidden {
                UIView.transitionWithView(adressTableView, duration: 0.5, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                    self.adressTableView.hidden = false
                    }, completion: nil)
            }
        
        } else {
            if !addressTextfield.hidden {
                UIView.transitionWithView(adressTableView, duration: 0.5, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
                    self.adressTableView.hidden = true
                    }, completion: nil)
            }
        }
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        currentLocationCoordinate = coordinate
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            print("Numero de resultadooos: \(response.results())")
            if let address = response?.firstResult() {
                if address.lines != nil {
                    let lines = address.lines as! [String]
                    let fullAddress = lines.joinWithSeparator(" - ")
                    let addressComponents = fullAddress.componentsSeparatedByString(" a ")
                    if let streetName = addressComponents.first {
                        self.addressTextfield.text = "\(streetName)"
                        self.addressDidChange(self.addressTextfield)
                    }
                    //self.addressTextfield.text = join("-", lines)
                }
            }
        }
    }
    
    //MARK: Actions 
    
    @IBAction func opacityButtonPressed() {
        mapView.userInteractionEnabled = true
        selectedLocationFromResultsTableView = false
        
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.alertConfirmView.alpha = 0.0
            }) { succeded -> Void in
                self.alertConfirmView.removeFromSuperview()
        }
    }
    
    @IBAction func confirmAddressButtonPressed() {
        alertConfirmView.endEditing(true)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alertConfirmView.alpha = 0.0
            }) { succeded -> Void in
                self.alertConfirmView.removeFromSuperview()
                self.sendAddressToPreviousVC(self.confirmAddressTextfield.text!, location: self.currentLocationCoordinate, selectingPickupLocation: self.wasSelectingPickupLocation)
                self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func addressDidChange(textField: UITextField) {
        print("cambie el texto del textfieldddd: \(textField.text!)")
        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        if !textField.text!.isEmpty {
            activityIndicator.startAnimating()
             timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(kTimerWaitingTime), target: self, selector: "searchAddressUsingGeocoding", userInfo: nil, repeats: false)
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func recentLocationsButtonPressed() {
        let addressHistoryVC = storyboard!.instantiateViewControllerWithIdentifier("AddressHistory") as! AddressHistoryViewController
        addressHistoryVC.delegate = self
        navigationController!.pushViewController(addressHistoryVC, animated: true)
    }
    
    @IBAction func locationChoosed(sender: AnyObject) {
        /*sendAddressToPreviousVC(addressTextfield.text!, location: currentLocationCoordinate, selectingPickupLocation: wasSelectingPickupLocation)
        navigationController?.popViewControllerAnimated(true)*/
    }
    
    //MARK: Custom Stuff
    
    func formatAddress(address: String) -> String {
        let lowercaseAddress = address.lowercaseString
        let shortAddress = lowercaseAddress.stringByReplacingOccurrencesOfString(", bogotá, bogotá, colombia", withString: "")
        return shortAddress.stringByReplacingOccurrencesOfString(", bogota, bogota, colombia", withString: "")
    }
    
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

//MARK: UITableViewDataSource

extension MapViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellId, forIndexPath: indexPath)
        
        if let formattedAddress = addressResults[indexPath.row]["formatted_address"] as? String {
            cell.textLabel?.text = formatAddress(formattedAddress)
        }
        return cell
    }
}

//MARK: UITableViewDelegate 

extension MapViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedLocationFromResultsTableView = true
        mapView.userInteractionEnabled = false
        
        let latitude = ((addressResults[indexPath.row]["geometry"] as! NSDictionary)["location"] as! NSDictionary)["lat"] as! CLLocationDegrees
        let longitude = ((addressResults[indexPath.row]["geometry"] as! NSDictionary)["location"] as! NSDictionary)["lng"] as! CLLocationDegrees
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let locationName = addressResults[indexPath.row]["formatted_address"] as! String
        
        addressTextfield.text = formatAddress(locationName)
        currentLocationCoordinate = locationCoordinate
        let cameraPosition = GMSCameraPosition(target: currentLocationCoordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.camera = cameraPosition
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        animateAddressTableView(show: false)
        
        alertConfirmView.alpha = 0.0
        alertConfirmView.frame = navigationController!.view.bounds
        confirmAddressTextfield.text = addressTextfield.text
        navigationController!.view.addSubview(alertConfirmView)
        
        delay(1.0) { () -> () in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.alertConfirmView.alpha = 1.0
                }, completion: { succeded -> Void in
                    self.confirmAddressTextfield.becomeFirstResponder()
            })
        }
    }
}

//MARK: UITextfieldDelegate

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 1 {
            //Main Address textfield
            print("Entre al begin editinggggggggg")
            addressDidChange(addressTextfield)
        }
    }
    
    /*func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("should change with replacement string: \(string)")
        activityIndicator.startAnimating()
        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(kTimerWaitingTime), target: self, selector: "searchAddressUsingGeocoding", userInfo: nil, repeats: false)
        return true
    }*/
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
                print("Entre al update de cuando si hay locacionnnn")
                mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: locationDic["lat"] as! CLLocationDegrees, longitude: locationDic["lon"] as! CLLocationDegrees), zoom: 15, bearing: 0, viewingAngle: 0)
                addressTextfield.text = locationDic["address"] as? String
            } else {
                print("Entre al update de cuando no hay locacionnnnnnn")
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
        if !selectedLocationFromResultsTableView {
            reverseGeocodeCoordinate(position.target)
        }
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
