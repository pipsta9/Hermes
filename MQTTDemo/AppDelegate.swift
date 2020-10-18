//
//  AppDelegate.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 3/24/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit
import CoreData
import CocoaMQTT
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var mqttx = CocoaMQTT(clientID: "iOS Device", host: "10.95.21.100", port: 1883)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        UIApplication.shared.isStatusBarHidden = false
//        UIApplication.shared.statusBarStyle = .lightContent
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        // Call the function to request permission and register for notifications
        self.registerForNotifications()
        
        var topics = [] as! [Topic]
        
        // Unarchive the topics array from user defaults
        
        let defaults = UserDefaults.standard
        
        if let topicsData = defaults.object(forKey: "Topics") as? Data {
            topics = NSKeyedUnarchiver.unarchiveObject(with: topicsData) as! [Topic]
        }
        
        // Check if the array exists and if not create it
        
        if topics.count == 0 {
            topics.append(Topic(name: "Abrasive Clean", subscribed: true))
            topics.append(Topic(name: "Assembly", subscribed: true))
            topics.append(Topic(name: "Bushing Install", subscribed: true))
            topics.append(Topic(name: "CNC", subscribed: true))
            topics.append(Topic(name: "Components", subscribed: true))
            topics.append(Topic(name: "Deburr", subscribed: true))
            topics.append(Topic(name: "Disassembly", subscribed: true))
            topics.append(Topic(name: "Electrical", subscribed: true))
            topics.append(Topic(name: "Machine Shop", subscribed: true))
            topics.append(Topic(name: "NDT", subscribed: true))
            topics.append(Topic(name: "Paint", subscribed: true))
            topics.append(Topic(name: "Planning", subscribed: true))
            topics.append(Topic(name: "Plating & Bake", subscribed: true))
            topics.append(Topic(name: "SPC", subscribed: true))
            topics.append(Topic(name: "Quality Control", subscribed: true))
            
            let data = NSKeyedArchiver.archivedData(withRootObject: topics)
            defaults.set(data, forKey: "Topics")
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Reset the badge counter
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Attempt to upate the alerts from the server
        NotificationCenter.default.post(name: .logUpdate, object: nil)
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Alerts")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Push Notification Support
    
    // Function to get the global device ID
    func getGlobalUniqueIdentifierFromKeyChain()->String{
        
        let retrievedString: String? = KeychainWrapper.standard.string(forKey: "DeviceId")
        
        if  retrievedString == nil{
            if let deviceKey  = UIDevice.current.identifierForVendor?.uuidString{
                let _ = KeychainWrapper.standard.set(deviceKey, forKey: "DeviceId")
            }
        }
        
        if let globalID = KeychainWrapper.standard.string(forKey: "DeviceId"){
            return globalID
        }else{
            return UIDevice.current.identifierForVendor?.uuidString ?? ""
        }
    }
    
    // Function calls when device successfully registers for push notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Get the device token
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        let deviceID = getGlobalUniqueIdentifierFromKeyChain()
        
        
        print("APNS Device Token: \(token)")                                    // SEND THE APNS DEVICE TOKEN TO SERVER WITH MQTT
        print("Device ID: \(getGlobalUniqueIdentifierFromKeyChain())") // CAN USE THE DEVICE ID AS A KEY TO PREVENT OLD TOKENS FROM STAYING ON THE LIST
 
        
        // Post a notification for the tab bar to publish the token and device ID to the MQTT broker
        NotificationCenter.default.post(name: .deviceToken, object: nil, userInfo: ["deviceID": deviceID, "token": token])
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register with APNs with Error: \(error)")
    }
    
    // Function to prompt user to allow notifications
    func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            self.getNotificationSettings()
            print("Permission granted: \(granted)")
        }
    }
    
    // Function to check user authorized notification settings
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            // Note: registerForRemoteNotifications() can only be run on the main thread
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
    }
    
    // Function to handle when a push notification is received
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Recived: \(userInfo)")
        completionHandler(.newData)
        // Call the function to create an alert and post the notification
        NotificationCenter.default.post(name: .receiveNewAlert, object: nil, userInfo: userInfo)
        
        NotificationCenter.default.post(name: .didReceiveAlert, object: nil)
        //self.createAlert(data: userInfo["aps"] as! NSDictionary)
        
        // Check if the app is in the foreground - If so, display an alert to notify user that a new item arrived
        if UIApplication.shared.applicationState == .active {
            let data = userInfo["aps"] as! NSDictionary
            
            // Get the properties from the dictionary
            let alertStatus = data["alertStatus"] ?? ""
            let description = data["description"] ?? ""
            let title = data["title"] ?? ""
            let name = data["name"] ?? ""
            var messageTitle: String = ""
            var message: String = ""
            let titleString = title as! String
            let nameString = name as! String
            
            // Check the alert status and update the message string accordingly
            if alertStatus as! String == "new" {
                messageTitle = "NEW ALERT!"
                message = "A new alert was received. Check the New Alerts tab for details."
            }
            else if alertStatus as! String == "inwork" {
                if description as! String != "" {
                    messageTitle = "Description updated"
                    message = "Description was updated for " + titleString + ". Check the detail view for details."
                }
                else {
                    messageTitle = "Alert accepted!"
                    message = titleString + " issue was accepted by " + nameString + ". Check the In Work tab for details."
                }
            }
            else if alertStatus as! String == "resolved" {
                messageTitle = "Alert resolved!"
                message = "An alert was resolved. Check the resolved tab for details."
            }
            
            // Create an alert view controller
            let alertController = UIAlertController(title: messageTitle, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            // Present the alert from the current active view controller
            var hostVC = self.window?.rootViewController
            while let next = hostVC?.presentedViewController {
                if next is UIAlertController {
                    hostVC?.dismiss(animated: true, completion: nil)
                    break
                } else {
                    hostVC = next
                }
            }
            hostVC?.present(alertController, animated: true, completion: nil)
        }
    }
    
    /*
    // Function to create an alert object when a notification is received
    // Note: This will not work if the user quits the app. 
    func createAlert(data: NSDictionary) {
        
        // Get the properties from the dictionary
        let title = data["location"] ?? "Default Title"
        let date = data["date"] as! String
        let time = data["time"] ?? ""
        let icon = data["alertIcon"] ?? ""
        
        // Create a new alert object in core data
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "NewAlerts", in: managedContext)!
        let alertsType = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Set the alert properties
        alertsType.setValue(title, forKeyPath: "alertTitle")
        alertsType.setValue("new", forKey: "alertStatus")
        alertsType.setValue(icon, forKey: "alertIcon")
        alertsType.setValue(date.toDate(), forKey: "date")
        alertsType.setValue(time, forKey: "timeStamp")
        alertsType.setValue(date.toDate().toStr(), forKey: "dateStamp")
        alertsType.setValue("DefaultID", forKey: "alertID")
        alertsType.setValue("", forKey: "alertDescription")
        alertsType.setValue("", forKey: "resolvedDate")
        alertsType.setValue("", forKey: "resolvedTime")
        
        // Save the new alert
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    */
}

// MARK: - Notification Center

extension Notification.Name {
    static let didReceiveAlert = Notification.Name ("didReceiveAlert")
    static let toggleSlideMenu = Notification.Name("toggleSlideMenu")
    static let updateSubs = Notification.Name("updateSubs")
    static let touchInMainView = Notification.Name("touchInMainView")
    static let descriptionUpdate = Notification.Name("descriptionUpdate")
    static let resolveUpdate = Notification.Name("resolveUpdate")
    static let logUpdate = Notification.Name("logUpdate")
    static let logUpdateResolve = Notification.Name("logUpdateResolve")
    static let changeToResolve = Notification.Name("changeToResolve")
    static let datePicker = Notification.Name("datePicker")
    static let receiveNewAlert = Notification.Name("receiveNewAlert")
    static let deviceToken = Notification.Name("deviceToken")
}
