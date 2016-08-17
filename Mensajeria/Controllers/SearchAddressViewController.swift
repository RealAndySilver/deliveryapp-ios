//
//  SearchAddressViewController.swift
//  Mensajeria
//
//  Created by Developer on 28/08/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

//Enums
enum GeocodingStatusCode: String {
    case Ok = "OK"
    case ZeroResults = "ZERO_RESULTS"
    case OverQueryLimit = "OVER_QUERY_LIMIT"
    case RequestDenied = "REQUEST_DENIED"
    case InvalidRequest = "INVALID_REQUEST"
    case UnknownError = "UNKNOWN_ERROR"
}

protocol SearchAddressViewControllerDelegate: class {
    func addressSelectedWithName(name: String, coordinates: CLLocationCoordinate2D)
}

class SearchAddressViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var searchAddressView: DesignableView!
    @IBOutlet weak var addressTextfield: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Internal variables
    weak var delegate: SearchAddressViewControllerDelegate?
    var address: String!
    @IBOutlet weak var resultsTableView: UITableView!
    
    //Private variables 
    private let kNorthEastLatitude = 4.80140167730285
    private let kNorthEastLongitude = -74.0019284561276
    private let kSouthWeastLatitude = 4.50541610527197
    private let kSouthWeastLongitude = -74.206731878221
    private var timer: NSTimer!
    private let kTimerWaitingTime = 3 //Seconds
    private var waitingForGeocodingResponse = false
    
    private let kCellId = "ResultAddressCell"
    private var resultsArray = [Dictionary<String, AnyObject>]()
    
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //MARK: View lifecycle & Initialization Stuff

    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.tableFooterView = UIView(frame: CGRectZero)
        addressTextfield.text = address
        if addressTextfield.text!.characters.count > 0 {
            searchAddressUsingGeocoding()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchAddressUsingGeocoding() {
        activityIndicator.startAnimating()
        
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
                        self.resultsArray = jsonResponse["results"].object as! [Dictionary<String , AnyObject>]
                        self.resultsTableView.reloadData()
                        
                    case .ZeroResults:
                        print("No results")
                    default:
                        print("Hubo un error la petición al Geocoding")
                    }
                }
            }
        }
    }
    
    //MARK: Actions 
    
    @IBAction func opacityButtonPressed() {
        searchAddressView.animation = "fall"
        searchAddressView.animate()
        delay(0.2) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

//MARK: UITableViewDataSource

extension SearchAddressViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellId, forIndexPath: indexPath) 
        cell.textLabel?.text = resultsArray[indexPath.row]["formatted_address"] as? String
        cell.detailTextLabel?.text = ""
        return cell
    }
}

//MARK: UITableViewDelegate 

extension SearchAddressViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let latitude = ((resultsArray[indexPath.row]["geometry"] as! NSDictionary)["location"] as! NSDictionary)["lat"] as! CLLocationDegrees
        let longitude = ((resultsArray[indexPath.row]["geometry"] as! NSDictionary)["location"] as! NSDictionary)["lng"] as! CLLocationDegrees
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let locationName = resultsArray[indexPath.row]["formatted_address"] as! String
        delegate?.addressSelectedWithName(locationName, coordinates: locationCoordinate)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: UITextFieldDelegate

extension SearchAddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("should change with replacement string: \(string)")
        activityIndicator.startAnimating()
        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(kTimerWaitingTime), target: self, selector: "searchAddressUsingGeocoding", userInfo: nil, repeats: false)
        return true
    }
}