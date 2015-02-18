//
//  RequestServiceViewController.swift
//  Mensajeria
//
//  Created by Diego Fernando Vidal Illera on 2/5/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class RequestServiceViewController: UIViewController {
    
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    
    enum TextfieldName: Int {
        case pickupTextfield = 1, finalTextfield, dayHourTextfield, shipmentValueTextfield
    }
    
    var pickupDatePicker: UIDatePicker!
    var deliveryDatePicker: UIDatePicker!
    @IBOutlet weak var deliveryDayHourTextfield: UITextField!
    @IBOutlet weak var pickupAddressTextfield: UITextField!
    @IBOutlet weak var finalAddressTextfield: UITextField!
    @IBOutlet weak var idaYVueltaSwitch: UISwitch!
    @IBOutlet weak var dayHourTextfield: UITextField!
    @IBOutlet weak var shipmentValueTextfield: UITextField!
    @IBOutlet weak var instructionsTextView: UITextView!
    var pickupLocationDic = [:]
    var destinationLocationDic = [:]
    lazy var dateFormatter: NSDateFormatter = {
        println("entre a nicializarrr")
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle
        formatter.locale = NSLocale.currentLocale()
        return formatter
    }()
    
    //Constants
    let savedPickupAdressesKey = "pickupAddresses"
    let savedDestinationAdressesKey = "destinationAddresses"
    let maxAllowedSavedAddresses = 10
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("entre acaaaa")
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("aparecereeee")
    }
    
    //MARK: UI Setup
    
    func setupUI() {
        instructionsTextView.layer.borderWidth = 1.0
        instructionsTextView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        instructionsTextView.layer.cornerRadius = 10.0
        
        pickupDatePicker = UIDatePicker()
        pickupDatePicker.addTarget(self, action: "dateChanged:", forControlEvents: .ValueChanged)
        dayHourTextfield.inputView = pickupDatePicker
        
        deliveryDatePicker = UIDatePicker()
        deliveryDatePicker.addTarget(self, action: "deliveryDateChanged:", forControlEvents: .ValueChanged)
        deliveryDayHourTextfield.inputView = deliveryDatePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.size.width, height: 44.0))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissPickers")
        toolBar.setItems([doneButton], animated: false)
        
        dayHourTextfield.inputAccessoryView = toolBar
        deliveryDayHourTextfield.inputAccessoryView = toolBar
        shipmentValueTextfield.inputAccessoryView = toolBar
        
        //Reveal button
        if revealViewController() != nil {
            revealButtonItem.target = revealViewController()
            revealButtonItem.action = "revealToggle:"
        }
    }
    
    //MARK: Actions
    @IBAction func addAdditionalAddressPressed() {
    
    }
    
    @IBAction func addressHistoryPressed() {
   
    }
    
    @IBAction func acceptButtonPressed() {
        //goToFindingServiceWithServiceID("")
        if formIsCorrect() {
            saveAddressInUserDefaults()
            sendServiceRequestToServer()
            //goToFindingServiceWithServiceID("")
            
        } else {
            UIAlertView(title: "Oops!", message: "No has completado todos los campos", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    func dateChanged(datePicker: UIDatePicker) {
        dayHourTextfield.text = dateFormatter.stringFromDate(datePicker.date)
        println(datePicker.date)
    }
    
    func deliveryDateChanged(datePicker: UIDatePicker) {
        deliveryDayHourTextfield.text = dateFormatter.stringFromDate(datePicker.date)
    }
    
    func dismissPickers() {
        dayHourTextfield.resignFirstResponder()
        deliveryDayHourTextfield.resignFirstResponder()
        shipmentValueTextfield.resignFirstResponder()
    }
    
    //MARK: Server Stuff
    
    func sendServiceRequestToServer() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        println("")
        Alamofire.manager.request(.POST, Alamofire.requestMensajeroServiceURL, parameters: ["user_id" : User.sharedInstance.identifier, "user_info" : User.sharedInstance.userDictionary, "pickup_object" : pickupLocationDic, "delivery_object" : destinationLocationDic, "roundtrip" : idaYVueltaSwitch.on, "instructions" : instructionsTextView.text, "priority" : 5, "deadline" : deliveryDatePicker.date, "declared_value" : shipmentValueTextfield.text, "price_to_pay" : 25000, "pickup_time" : pickupDatePicker.date], encoding: ParameterEncoding.URL).responseJSON { (request, response, json, error) in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            if error != nil {
                //There was an error
                println("Hubo error en el request: \(error?.localizedDescription)")
                UIAlertView(title: "Oops", message: "Hubo un error en el servidor. Por favor intenta de nuevo en un momento", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Successful response 
                let jsonResponse = JSON(json!)
                println("Respuesta correcta del request: \(jsonResponse)")
                if jsonResponse["status"].boolValue {
                    let deliveryItem = DeliveryItem(deliveryItemJSON: JSON(jsonResponse["response"].object))
                    self.goToFindingServiceWithServiceID(deliveryItem.identifier)
                    println("id del servicio: \(deliveryItem.identifier)")
                    println("Descripcion completa del delivery item parseado: \(deliveryItem.deliveryItemDescription)")
                    /*if let requestID = jsonResponse["response"]["_id"].string {
                        self.goToFindingServiceWithServiceID(requestID)
                    }*/
                } else {
                    println("Llego en false el request: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al pedir el servicio. Por favor intenta de nuevo en un momento", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    //MARK: Form Validation
    
    func formIsCorrect() -> Bool {
        var pickupAddressIsCorrect = false
        var finalAddressIsCorrect = false
        var dayAndHourIsCorrect = false
        var instructionsAreCorrect = false
        var deliveryDayHourIsCorrect = false
    
        if countElements(pickupAddressTextfield.text) > 0 {
            pickupAddressIsCorrect = true
            pickupAddressTextfield.layer.borderWidth = 0.0
        } else {
            pickupAddressTextfield.layer.borderWidth = 1.0
            pickupAddressTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if countElements(finalAddressTextfield.text) > 0 {
            finalAddressIsCorrect = true
            finalAddressTextfield.layer.borderWidth = 0.0
        } else {
            finalAddressTextfield.layer.borderColor = UIColor.redColor().CGColor
            finalAddressTextfield.layer.borderWidth = 1.0
        }
        
        if countElements(dayHourTextfield.text) > 0 {
            dayAndHourIsCorrect = true
            dayHourTextfield.layer.borderWidth = 0.0
        } else {
            dayHourTextfield.layer.borderWidth = 1.0
            dayHourTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if countElements(deliveryDayHourTextfield.text) > 0 {
            deliveryDayHourIsCorrect = true
            deliveryDayHourTextfield.layer.borderWidth = 0.0
        } else {
            deliveryDayHourTextfield.layer.borderWidth = 1.0
            deliveryDayHourTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if countElements(instructionsTextView.text) > 0 {
            instructionsAreCorrect = true
            instructionsTextView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        } else {
            instructionsTextView.layer.borderColor = UIColor.redColor().CGColor
        }
        
        return pickupAddressIsCorrect && finalAddressIsCorrect && dayAndHourIsCorrect && instructionsAreCorrect && deliveryDayHourIsCorrect ? true : false
    }
    
    //MARK: Navigation
    
    func goToFindingServiceWithServiceID(serviceID: String) {
        let findingServiceVC = storyboard?.instantiateViewControllerWithIdentifier("FindingService") as FindingServiceViewController
        findingServiceVC.serviceID = serviceID
        navigationController?.pushViewController(findingServiceVC, animated: true)
    }
    
    func goToMapVCFromPickupTextfield(pickupSelected: Bool) {
        if let mapVC = storyboard?.instantiateViewControllerWithIdentifier("Map") as? MapViewController {
            mapVC.wasSelectingPickupLocation = pickupSelected
            mapVC.onAddressAvailable = {[weak self]
                (theAddress, theCoordinates, selectedPickupLocation) in
                if let weakSelf = self {
                    weakSelf.updatePickupAddress(theAddress, location: theCoordinates, selectedPickupLocation: selectedPickupLocation)
                }
            }
            navigationController?.pushViewController(mapVC, animated: true)
        }
    }
    
    //MARK: Custom Stuff
    
    func updatePickupAddress(address: String, location: CLLocationCoordinate2D, selectedPickupLocation: Bool) {
        println("latitude: \(location.latitude)")
        println("longitude: \(location.longitude)")
        println("selected pickup: \(selectedPickupLocation)")
        if selectedPickupLocation {
            pickupAddressTextfield.text = address
            //Update our pickup location dic
            pickupLocationDic = ["lat" : location.latitude, "lon" : location.longitude, "address" : address]
            
        } else {
            finalAddressTextfield.text = address
            //Update our destination location dic
            destinationLocationDic = ["lat" : location.latitude, "lon" : location.longitude, "address" : address]
        }
    }
    
    //MARK: Data Saving 
    
    func saveAddressInUserDefaults() {
        //Save pickup address 
        var pickupAddressDic = [String : AnyObject]()
        pickupAddressDic["dateSaved"] = dateFormatter.stringFromDate(NSDate())
        pickupAddressDic["address"] = pickupAddressTextfield.text
        pickupAddressDic["lat"] = pickupLocationDic["lat"]
        pickupAddressDic["lon"] = pickupLocationDic["lon"]
        
        if var pickupAddresses = NSUserDefaults.standardUserDefaults().objectForKey(savedPickupAdressesKey) as? [[String: AnyObject]] {
            println("Ya existia el arreglo de direcciones")
            pickupAddresses.insert(pickupAddressDic, atIndex: 0)
            if pickupAddresses.count > maxAllowedSavedAddresses {
                pickupAddresses.removeLast()
            }
            NSUserDefaults.standardUserDefaults().setObject(pickupAddresses, forKey: savedPickupAdressesKey)
            
        } else {
            println("No existía el arreglo de direcciones")
            let addressesArray = [pickupAddressDic]
            NSUserDefaults.standardUserDefaults().setObject(addressesArray, forKey: savedPickupAdressesKey)
        }
        
        //Save destination address
        var destinationAddressesDic = [String : AnyObject]()
        destinationAddressesDic["dateSaved"] = dateFormatter.stringFromDate(NSDate())
        destinationAddressesDic["address"] = finalAddressTextfield.text
        destinationAddressesDic["lat"] = destinationLocationDic["lat"]
        destinationAddressesDic["lon"] = destinationLocationDic["lon"]
        
        if var destinationAddresses = NSUserDefaults.standardUserDefaults().objectForKey(savedDestinationAdressesKey) as? [[String : AnyObject]] {
            destinationAddresses.insert(destinationAddressesDic, atIndex: 0)
            if destinationAddresses.count > maxAllowedSavedAddresses {
                destinationAddresses.removeLast()
            }
            NSUserDefaults.standardUserDefaults().setObject(destinationAddresses, forKey: savedDestinationAdressesKey)
        } else {
            let destinationAddressesArray = [destinationAddressesDic]
            NSUserDefaults.standardUserDefaults().setObject(destinationAddressesArray, forKey: savedDestinationAdressesKey)
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddressHistorySegue" {
            let addressHistoryVC = segue.destinationViewController as AddressHistoryViewController
            addressHistoryVC.delegate = self
        }
    }
}

//MARK: UITextfieldDelegate

extension RequestServiceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        println("Empzaré a editar el textfield \(textField.tag)")
        if textField.tag == TextfieldName.pickupTextfield.rawValue {
            goToMapVCFromPickupTextfield(true)
            return false
        
        } else if textField.tag == TextfieldName.finalTextfield.rawValue {
            goToMapVCFromPickupTextfield(false)
            return false
        } else {
            return true
        }
    }
}

//MARK: UITextviewDelegate

extension RequestServiceViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK: AddressHistoryDelegate

extension RequestServiceViewController: AddressHistoryDelegate {
    func addressSelected(adressDic: [String : AnyObject], forPickupLocation: Bool) {
        if forPickupLocation {
            pickupLocationDic = adressDic
            pickupAddressTextfield.text = pickupLocationDic["address"] as String!
        } else {
            destinationLocationDic = adressDic
            finalAddressTextfield.text = destinationLocationDic["address"] as String!
        }
    }
}


