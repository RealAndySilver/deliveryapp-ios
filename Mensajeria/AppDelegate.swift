//
//  AppDelegate.swift
//  Mensajeria
//
//  Created by Developer on 4/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyC1iFx0VxvU0WpB7gyPksl3gph7oOXxj5k")
        
        UINavigationBar.appearance().barTintColor = UIColor.getPrimaryAppColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        println("Entre al handle url")
        if url.absoluteString?.lowercaseString.rangeOfString("password_redirect") != nil {
            let urlString = url.absoluteString
            let parametersDic = Utils.URLQueryParameters(url)
            let token = parametersDic["token"] as String
            let userType = parametersDic["type"] as String
            let requestType = parametersDic["request"] as String
            println("token: \(token)")
            println("user type: \(userType)")
            println("request type: \(requestType)")
            
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
    
    func showPasswordView() {
        let passwordView = PasswordView(frame: CGRectMake(window!.bounds.size.width/2.0 - 140.0, window!.bounds.size.height/2.0 - 147.0, 280.0, 194.0))
        passwordView.showInWindow(window!)
    }
}

