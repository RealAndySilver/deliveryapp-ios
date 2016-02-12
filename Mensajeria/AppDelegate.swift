//
//  AppDelegate.swift
//  Mensajeria
//
//  Created by Developer on 4/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
// julian.montana@gmail.com

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appToken: String?
    var deliveryItemId: String!
    var currentServiceDetailScreenDeliveryItemID = ""
    var onWaitingForConfirmationScreen = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyAromUOb3aQM6vmFpf_Rn218zE_gErSV38")
        
        UINavigationBar.appearance().barTintColor = UIColor.getPrimaryAppColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        //Register for remote notifications
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        if let pendingRatingDic = NSUserDefaults.standardUserDefaults().objectForKey("pendingRatingDicKey") as? [String : String] {
            print("Existe un mensajero sin rating *************************************************")
            delay(3.0, closure: { () -> () in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let pendingRateVC = storyboard.instantiateViewControllerWithIdentifier("PendingRate") as! PendingRateViewController
                pendingRateVC.modalPresentationStyle = .OverCurrentContext
                pendingRateVC.modalTransitionStyle = .CrossDissolve
                pendingRateVC.messengerDic = pendingRatingDic
                
                //let navigationController = UINavigationController(rootViewController: pendingRateVC)
                self.window?.makeKeyAndVisible()
                
                let topRootViewController = self.window?.rootViewController!
                if let topVC = topRootViewController {
                    if let presentedVC = topVC.presentedViewController {
                        presentedVC.presentViewController(pendingRateVC, animated: true, completion: nil)
                    }
                } else {
                    topRootViewController?.presentViewController(pendingRateVC, animated: true, completion: nil)
                }
            })
            
        } else {
            print("No existe un rating dic de mensajero")
        }
        
        /////////////////////////////////////////////////////////////////
        //Get the list of insurance values 
        getInsurancesValues()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSNotificationCenter.defaultCenter().postNotificationName("AppDidBecomeActiveNotification", object: nil)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        print("Entre al handle url")
        if url.absoluteString.lowercaseString.rangeOfString("password_redirect") != nil {
            //let urlString = url.absoluteString
            let parametersDic = Utils.URLQueryParameters(url)
            let token = parametersDic["token"] as! String
            let userType = parametersDic["type"] as! String
            let requestType = parametersDic["request"] as! String
            print("token: \(token)")
            print("user type: \(userType)")
            print("request type: \(requestType)")
            
            if requestType == "new_password" {
                NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token")
                NSUserDefaults.standardUserDefaults().setObject(userType, forKey: "userType")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //Show the password view after a little delay of 1 second
                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), { () -> Void in
                    self.showPasswordView()
                })
            }
            
            return true
        } else {
            return false
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Receive remote notification: \(userInfo)")
        
        if NSUserDefaults.standardUserDefaults().objectForKey("UserInfo") != nil {
            //Handle push only if the user is log in
            let apsDic = userInfo["aps"] as! [String : AnyObject]
            let message = apsDic["alert"] as! String
            if userInfo["u_type"] as! String == "user" && userInfo["action"] as! String == "delivery" {
                
                deliveryItemId = userInfo["id"] as! String
                print("id del servicio que llego en la notificacion: \(deliveryItemId)")
                print("id del currentservicedetailid: \(currentServiceDetailScreenDeliveryItemID)")
                if deliveryItemId != currentServiceDetailScreenDeliveryItemID && !onWaitingForConfirmationScreen {
                    print("id del servicio: \(deliveryItemId)")
                    let appState = UIApplication.sharedApplication().applicationState
                    if appState == .Active {
                        print("the app was active when the notification arrived")
                        UIAlertView(title: "Servicio actualizado", message: "\(message) ¿Quieres acceder al detalle del servicio?", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Aceptar").show()
                        
                    } else {
                        UIAlertView(title: "Servicio actualizado", message: "\(message) ¿Quieres acceder al detalle del servicio?", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Aceptar").show()
                        print("the app was inactive when the notification arrived")
                    }
                    
                } else {
                    //The user was in the service screen when the notification arrived, so update the service
                    NSNotificationCenter.defaultCenter().postNotificationName("ServiceUpdatedNotification", object: nil)
                    UIAlertView(title: "Servicio Actualizado", message: "\(message)", delegate: nil, cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("error registrandome para las notificacciones: \(error.localizedDescription)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.description
        var trimmedToken = token.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        trimmedToken = trimmedToken.stringByReplacingOccurrencesOfString(" ", withString: "")
        appToken = trimmedToken
        print("Tokeeen: \(trimmedToken)")
    }
    
    func showPasswordView() {
        let passwordView = PasswordView(frame: CGRectMake(window!.bounds.size.width/2.0 - 140.0, window!.bounds.size.height/2.0 - 147.0, 280.0, 194.0))
        passwordView.showInWindow(window!)
    }
    
    //MARK: Server 
    
    func getInsurancesValues() {
        ServerRequests.getInsurancesValues { result in
            switch result {
            case .Failure(let error):
                print("Error in the get insurances values: \(error.localizedDescription)")
            case .Success(let value):
                let jsonResponse = JSON(value)
                print("Success in the get insurances value: \(jsonResponse)")
                if jsonResponse["status"].boolValue {
                    if let insurancesValues = jsonResponse["response"].object as? [Int] {
                        AppInfo.sharedInstance.insurancesValues = insurancesValues
                    }
                }
            }
        }
    }
    
    func getDeliveryItemId() {
        
        let request = NSMutableURLRequest.createURLRequestWithHeaders("\(Alamofire.getDeliveryItemServiceURL)/\(deliveryItemId)", methodType: "GET")
        if request == nil { return }
        
        Alamofire.manager.request(request!).responseJSON { (response) -> Void in
            
            if case .Failure(let error) = response.result {
                //There was an error
                print("error en el get delivery item: \(error.localizedDescription)")
            } else {
                //Success
                let jsonResponse = JSON(response.result.value!)
                if jsonResponse["status"].boolValue {
                    //True response 
                    print("respuesta true del get delivery item by id: \(jsonResponse)")
                    let deliveryItem = DeliveryItem(deliveryItemJSON: jsonResponse["response"])
                    
                    //go to delivery item detail
                    self.goToDeliveryItemDetail(deliveryItem)
                    
                } else {
                    //False response
                }
            }
        }
    }
    
    func goToDeliveryItemDetail(deliveryItem: DeliveryItem) {
        print("iré al delivery iteeeeemmmmmm")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let serviceAcceptedVC = storyboard.instantiateViewControllerWithIdentifier("ServiceAccepted") as! ServiceAcceptedViewController
        serviceAcceptedVC.deliveryItem = deliveryItem
        serviceAcceptedVC.presentedFromPushNotification = true
        serviceAcceptedVC.presentedFromFindingServiceVC = false
        serviceAcceptedVC.presentedFromFinishedServicesVC = false
        
        let navigationController = UINavigationController(rootViewController: serviceAcceptedVC)
        window?.makeKeyAndVisible()
        
        let topRootViewController = window?.rootViewController!
        if var topVC = topRootViewController {
            topVC = topVC.presentedViewController!
            topVC.presentViewController(navigationController, animated: true, completion: nil)
        } else {
            topRootViewController?.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
}

extension AppDelegate: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        print("button index: \(buttonIndex)")
        if buttonIndex == 1 {
            //Present delivery item detail view controller
            //Get delivery item 
            getDeliveryItemId()
        }
    }
}

