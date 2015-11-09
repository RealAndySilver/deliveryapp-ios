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
        case pickupTextfield = 1, finalTextfield, dayHourTextfield, deliveryTextField, valorDeclaradoTextfield, valorAseguradoTextField
    }
    
    enum PickerViewType: Int {
        case pickupPicker = 1
        case deliveryPicker = 2
        case valorAseguradoPicker = 3
    }
    
    var firstTimePickupTextFieldAppears = false
    var firstTimeDeliveryTextFieldAppears = false
    var firstTimeValorAseguradoTextFieldAppears = false
    let valorAseguradoCases: [(serverString: String, displayString: String)] = [("500000", "Hasta $500.000"), ("1000000", "Hasta $1000.000"), ("2000000", "Hasta $2.000.000")]
    let pickupAndDeliveryCases: [(serverString: String, displayString: String)] = [("now", "Inmediato"), ("later", "Durante el día")]
    var selectedPickupCase: (serverString: String, displayString: String)!
    var selectedDeliveryCase: (serverString: String, displayString: String)!
    var selectedValorAseguradoCase: (serverString: String, displayString: String)?
    @IBOutlet weak var servicePriceLabel: UILabel!
    @IBOutlet weak var insurancePriceLabel: UILabel!
    var pickupPicker: UIPickerView!
    var deliveryPicker: UIPickerView!
    var valorAseguradoPicker: UIPickerView!
    @IBOutlet weak var valorAseguradoTextField: UITextField!
    @IBOutlet weak var asegurarSwitch: UISwitch!
    @IBOutlet weak var deliveryAddressLabel: UILabel!
    @IBOutlet weak var serviceNameTextfield: UITextField!
    @IBOutlet weak var deliveryDayHourTextfield: UITextField!
    @IBOutlet weak var pickupAddressTextfield: UITextField!
    @IBOutlet weak var finalAddressTextfield: UITextField!
    @IBOutlet weak var idaYVueltaSwitch: UISwitch!
    @IBOutlet weak var dayHourTextfield: UITextField!
    @IBOutlet weak var shipmentValueTextfield: UITextField!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var sendImageSwitch: UISwitch!
    private var activeTextfield: UITextField?
    var pickupLocationDic = [String : AnyObject]()
    var destinationLocationDic = [String : AnyObject]()
    lazy var dateFormatter: NSDateFormatter = {
        print("entre a nicializarrr")
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
        print("entre acaaaa")
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("aparecereeee")
    }
 
    //MARK: UI Setup
    
    func setupUI() {
        instructionsTextView.layer.borderWidth = 1.0
        instructionsTextView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        instructionsTextView.layer.cornerRadius = 10.0
        
        /*pickupDatePicker = UIDatePicker()
        pickupDatePicker.addTarget(self, action: "dateChanged:", forControlEvents: .ValueChanged)
        dayHourTextfield.inputView = pickupDatePicker
        
        deliveryDatePicker = UIDatePicker()
        deliveryDatePicker.addTarget(self, action: "deliveryDateChanged:", forControlEvents: .ValueChanged)
        deliveryDayHourTextfield.inputView = deliveryDatePicker*/
        
        pickupPicker = UIPickerView()
        pickupPicker.delegate = self
        pickupPicker.dataSource = self
        pickupPicker.tag = PickerViewType.pickupPicker.rawValue
        dayHourTextfield.inputView = pickupPicker
        
        deliveryPicker = UIPickerView()
        deliveryPicker.delegate = self
        deliveryPicker.tag = PickerViewType.deliveryPicker.rawValue
        deliveryPicker.dataSource = self
        deliveryDayHourTextfield.inputView = deliveryPicker
        
        valorAseguradoPicker = UIPickerView()
        valorAseguradoPicker.delegate = self
        valorAseguradoPicker.dataSource = self
        valorAseguradoPicker.tag = PickerViewType.valorAseguradoPicker.rawValue
        valorAseguradoTextField.inputView = valorAseguradoPicker
        
        
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
        
        if !asegurarSwitch.on {
            valorAseguradoTextField.enabled = false
        }
    }
    
    //MARK: Actions
    
    @IBAction func asegurarSwitchPressed(sender: UISwitch) {
        if sender.on {
            valorAseguradoTextField.enabled = true
        } else {
            valorAseguradoTextField.enabled = false
        }
    }
    
    @IBAction func idaYVueltaSwitchPressed(sender: UISwitch) {
        if sender.on { deliveryAddressLabel.text = "Dirección Intermedia" }
        else { deliveryAddressLabel.text = "Dirección de Entrega"}
    }                                          
    
    @IBAction func tapButtonPressed(sender: UITapGestureRecognizer) {
        instructionsTextView.resignFirstResponder()
        if let activeTextfield = activeTextfield {
            activeTextfield.resignFirstResponder()
        }
    }
    
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
        print(datePicker.date)
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
    
    func getServicePrice() {
        /*if pickupLocationDic["lat"] != nil && pickupLocationDic["lon"] != nil && destinationLocationDic["lat"] != nil && destinationLocationDic["lon"] != nil {
            //See if the user has a insurance value selected and send it as a parameter*/
        /*var selectedInsuranceValue = ""
        if let selectedInsurance = selectedValorAseguradoCase {
            selectedInsuranceValue = selectedInsurance.serverString
        }*/
        var selectedInsuranceValue = selectedValorAseguradoCase?.serverString ?? ""
        if !asegurarSwitch.on { selectedInsuranceValue = "" }
        
        let pickupLatitude = (pickupLocationDic["lat"] as? CLLocationDegrees) ?? 0
        let pickupLongitude = (pickupLocationDic["lon"] as? CLLocationDegrees) ?? 0
        let deliveryLatitude = (destinationLocationDic["lat"] as? CLLocationDegrees) ?? 0
        let deliveryLongitude = (destinationLocationDic["lon"] as? CLLocationDegrees) ?? 0
        print("url del request: \(Alamofire.GetDeliveryPriceServiceURL)/\(pickupLatitude),\(pickupLongitude)/\(deliveryLatitude),\(deliveryLongitude)")
        
        let mutableURLRequest = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.GetDeliveryPriceServiceURL)/\(pickupLatitude),\(pickupLongitude)/\(deliveryLatitude),\(deliveryLongitude)/\(selectedInsuranceValue)", methodType: "GET")
        if mutableURLRequest == nil { return }
        
        Alamofire.manager.request(mutableURLRequest!).responseJSON(completionHandler: { (response) -> Void in
            
            if case .Failure(let error) = response.result {
                print("Hubo un erorr en el get price: \(error.localizedDescription)")
                self.servicePriceLabel.text = "COP $0"
                
            } else {
                //Success
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    print("Llego en true el get prices: \(jsonResponse)")
                    //Update price label
                    let servicePrice = jsonResponse["value"].intValue
                    self.servicePriceLabel.text = "COP $\(servicePrice)"
                    
                } else {
                    print("Llego en false el get prices: \(jsonResponse)")
                    self.servicePriceLabel.text = "COP $0"
                }
                
                if let insuranceValue = jsonResponse["insurance"].int {
                    self.insurancePriceLabel.text = "COP $\(insuranceValue)"
                } else {
                    self.insurancePriceLabel.text = "COP $0"
                }
            }
        })
    }
    
    //time_to_pickup , time_to_deliver
    func sendServiceRequestToServer() {
        MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        
        "insurancevalue"
        var insuranceValueString = ""
        if let selectedInsurance = selectedValorAseguradoCase {
            insuranceValueString = selectedInsurance.serverString
        }
        
        let urlParameters: [String : AnyObject] = ["user_id" : User.sharedInstance.identifier, "user_info" : User.sharedInstance.userDictionary, "pickup_object" : pickupLocationDic, "delivery_object" : destinationLocationDic, "roundtrip" : idaYVueltaSwitch.on, "instructions" : instructionsTextView.text!, "priority" : 5, "declared_value" : shipmentValueTextfield.text!, "price_to_pay" : 25000, "item_name" : serviceNameTextfield.text!, "time_to_pickup" : selectedPickupCase.serverString, "time_to_deliver" : selectedDeliveryCase.serverString, "send_image" : sendImageSwitch.on, "insurancevalue" : insuranceValueString]
        
        let mutableURLRequest = NSMutableURLRequest.createURLRequestWithHeaders(Alamofire.requestMensajeroServiceURL, methodType: "POST", theParameters: urlParameters)
        
        if mutableURLRequest == nil {
            print("Error creando el request, está en nil")
            return
        }
        
        Alamofire.manager.request(mutableURLRequest!).responseJSON { (response) -> Void in
        
            MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
            if case .Failure(let error) = response.result {
                //There was an error
                print("Hubo error en el request: \(error.localizedDescription)")
                UIAlertView(title: "Oops", message: "Hubo un error en el servidor. Por favor intenta de nuevo en un momento", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                //Successful response 
                let jsonResponse = JSON(response.result.value!)
                print("Respuesta correcta del request: \(jsonResponse)")
                if jsonResponse["status"].boolValue {
                    let deliveryItem = DeliveryItem(deliveryItemJSON: JSON(jsonResponse["response"].object))
                    self.goToFindingServiceWithServiceID(deliveryItem.identifier)
                    print("id del servicio: \(deliveryItem.identifier)")
                    print("Descripcion completa del delivery item parseado: \(deliveryItem.deliveryItemDescription)")
                    self.cleanUIFields()
                    /*if let requestID = jsonResponse["response"]["_id"].string {
                        self.goToFindingServiceWithServiceID(requestID)
                    }*/
                } else {
                    print("Llego en false el request: \(jsonResponse)")
                    UIAlertView(title: "Oops!", message: "Ocurrió un error al pedir el servicio. Por favor intenta de nuevo en un momento", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    //MARK: Form Validation
    
    func formIsCorrect() -> Bool {
        var serviceNameIsCorrect = false
        var pickupAddressIsCorrect = false
        var finalAddressIsCorrect = false
        var dayAndHourIsCorrect = false
        var instructionsAreCorrect = false
        var deliveryDayHourIsCorrect = false
        
        if serviceNameTextfield.text!.characters.count > 0 {
            serviceNameIsCorrect = true
            serviceNameTextfield.layer.borderWidth = 0.0
        } else {
            serviceNameTextfield.layer.borderColor = UIColor.redColor().CGColor
            serviceNameTextfield.layer.borderWidth = 1.0
        }
    
        if pickupAddressTextfield.text!.characters.count > 0 {
            pickupAddressIsCorrect = true
            pickupAddressTextfield.layer.borderWidth = 0.0
        } else {
            pickupAddressTextfield.layer.borderWidth = 1.0
            pickupAddressTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if finalAddressTextfield.text!.characters.count > 0 {
            finalAddressIsCorrect = true
            finalAddressTextfield.layer.borderWidth = 0.0
        } else {
            finalAddressTextfield.layer.borderColor = UIColor.redColor().CGColor
            finalAddressTextfield.layer.borderWidth = 1.0
        }
        
        if dayHourTextfield.text!.characters.count > 0 {
            dayAndHourIsCorrect = true
            dayHourTextfield.layer.borderWidth = 0.0
        } else {
            dayHourTextfield.layer.borderWidth = 1.0
            dayHourTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if deliveryDayHourTextfield.text!.characters.count > 0 {
            deliveryDayHourIsCorrect = true
            deliveryDayHourTextfield.layer.borderWidth = 0.0
        } else {
            deliveryDayHourTextfield.layer.borderWidth = 1.0
            deliveryDayHourTextfield.layer.borderColor = UIColor.redColor().CGColor
        }
        
        if instructionsTextView.text.characters.count > 0 {
            instructionsAreCorrect = true
            instructionsTextView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        } else {
            instructionsTextView.layer.borderColor = UIColor.redColor().CGColor
        }
        
        let shipmentVal = Int(shipmentValueTextfield.text!) ?? 0
        if shipmentVal < 2000 || shipmentVal > 2_000_000 {
            return false
        }
        
        return serviceNameIsCorrect && pickupAddressIsCorrect && finalAddressIsCorrect && dayAndHourIsCorrect && instructionsAreCorrect && deliveryDayHourIsCorrect ? true : false
    }
    
    //MARK: Navigation
    
    func goToFindingServiceWithServiceID(serviceID: String) {
        let findingServiceVC = storyboard?.instantiateViewControllerWithIdentifier("FindingService") as! FindingServiceViewController
        findingServiceVC.serviceID = serviceID
        navigationController?.pushViewController(findingServiceVC, animated: true)
    }
    
    func goToMapVCFromPickupTextfield(pickupSelected: Bool) {
        if let mapVC = storyboard?.instantiateViewControllerWithIdentifier("Map") as? MapViewController {
            if pickupSelected {
                //Check if theres a location in this textfield and pass it to the map vc to display the location
                if let _ = pickupLocationDic["lat"] as? CLLocationDegrees {
                    if let _ = pickupLocationDic["lon"] as? CLLocationDegrees {
                        mapVC.locationDic = pickupLocationDic
                    }
                }
            
            } else {
                if let _ = destinationLocationDic["lat"] as? CLLocationDegrees {
                    if let _ = destinationLocationDic["lon"] as? CLLocationDegrees {
                        mapVC.locationDic = destinationLocationDic
                    }
                }
            }
            
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
    
    func cleanUIFields() {
        servicePriceLabel.text = nil
        serviceNameTextfield.text = nil
        deliveryDayHourTextfield.text = ""
        pickupAddressTextfield.text = ""
        finalAddressTextfield.text = ""
        idaYVueltaSwitch.on = false
        dayHourTextfield.text = ""
        shipmentValueTextfield.text = ""
        instructionsTextView.text = ""
        destinationLocationDic = [:]
        pickupLocationDic = [:]
        asegurarSwitch.on = false
        sendImageSwitch.on = false
        selectedValorAseguradoCase = nil
        valorAseguradoTextField.text = ""
    }
    
    func updatePickupAddress(address: String, location: CLLocationCoordinate2D, selectedPickupLocation: Bool) {
        print("latitude: \(location.latitude)")
        print("longitude: \(location.longitude)")
        print("selected pickup: \(selectedPickupLocation)")
        if selectedPickupLocation {
            pickupAddressTextfield.text = address
            //Update our pickup location dic
            pickupLocationDic = ["lat" : location.latitude, "lon" : location.longitude, "address" : address]
            
        } else {
            finalAddressTextfield.text = address
            //Update our destination location dic
            destinationLocationDic = ["lat" : location.latitude, "lon" : location.longitude, "address" : address]
        }
        
        getServicePrice()
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
            print("Ya existia el arreglo de direcciones")
            pickupAddresses.insert(pickupAddressDic, atIndex: 0)
            if pickupAddresses.count > maxAllowedSavedAddresses {
                pickupAddresses.removeLast()
            }
            NSUserDefaults.standardUserDefaults().setObject(pickupAddresses, forKey: savedPickupAdressesKey)
            
        } else {
            print("No existía el arreglo de direcciones")
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
            let addressHistoryVC = segue.destinationViewController as! AddressHistoryViewController
            addressHistoryVC.delegate = self
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//IMPLEMENTACIÓN DE PROTOCOLOS

//MARK: UIPickerViewDataSource

extension RequestServiceViewController: UIPickerViewDataSource {
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case PickerViewType.deliveryPicker.rawValue, PickerViewType.pickupPicker.rawValue:
            return pickupAndDeliveryCases.count
        case PickerViewType.valorAseguradoPicker.rawValue:
            return valorAseguradoCases.count
        default:
            return 0
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
}

//MARK: UIPickerViewDelegate

extension RequestServiceViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case PickerViewType.deliveryPicker.rawValue, PickerViewType.pickupPicker.rawValue:
            return pickupAndDeliveryCases[row].displayString
        case PickerViewType.valorAseguradoPicker.rawValue:
            return valorAseguradoCases[row].displayString
        default:
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case PickerViewType.pickupPicker.rawValue:
            dayHourTextfield.text = pickupAndDeliveryCases[row].displayString
            selectedPickupCase = pickupAndDeliveryCases[row]
        case PickerViewType.deliveryPicker.rawValue:
            deliveryDayHourTextfield.text = pickupAndDeliveryCases[row].displayString
            selectedDeliveryCase = pickupAndDeliveryCases[row]
        case PickerViewType.valorAseguradoPicker.rawValue:
            valorAseguradoTextField.text = valorAseguradoCases[row].displayString
            selectedValorAseguradoCase = valorAseguradoCases[row]
            getServicePrice()
        default:
            break
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
        print("Empzaré a editar el textfield \(textField.tag)")
        if textField.tag == TextfieldName.pickupTextfield.rawValue {
            goToMapVCFromPickupTextfield(true)
            return false
        
        } else if textField.tag == TextfieldName.finalTextfield.rawValue {
            goToMapVCFromPickupTextfield(false)
            return false
        } else {
            activeTextfield = textField
            return true
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == TextfieldName.dayHourTextfield.rawValue && !firstTimePickupTextFieldAppears {
            dayHourTextfield.text = pickupAndDeliveryCases[0].displayString
            selectedPickupCase = pickupAndDeliveryCases[0]
            firstTimePickupTextFieldAppears = true
        
        } else if textField.tag == TextfieldName.deliveryTextField.rawValue && !firstTimeDeliveryTextFieldAppears {
            deliveryDayHourTextfield.text = pickupAndDeliveryCases[0].displayString
            selectedDeliveryCase = pickupAndDeliveryCases[0]
            firstTimeDeliveryTextFieldAppears = true
        
        } else if textField.tag == TextfieldName.valorAseguradoTextField.rawValue && !firstTimeValorAseguradoTextFieldAppears {
            valorAseguradoTextField.text = valorAseguradoCases[0].displayString
            selectedValorAseguradoCase = valorAseguradoCases[0]
            firstTimeValorAseguradoTextFieldAppears = true
            getServicePrice()
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
            pickupAddressTextfield.text = pickupLocationDic["address"] as? String
        } else {
            destinationLocationDic = adressDic
            finalAddressTextfield.text = destinationLocationDic["address"] as? String
        }
        getServicePrice()
    }
}


