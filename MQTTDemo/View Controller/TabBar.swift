//
//  TabBar.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 7/29/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit
import CocoaMQTT
import CoreData

class TabBar: UITabBarController {
    
    var mqttx: CocoaMQTT!
    var text: CocoaMQTTMessage!
    var alertsArray: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mqttConnection()
        
        NotificationCenter.default.addObserver(self, selector: #selector(mqttConnection), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(descriptionUpdateServer), name: .descriptionUpdate, object: nil) //Send description update to server
        NotificationCenter.default.addObserver(self, selector: #selector(resolveUpdateServer), name: .resolveUpdate, object: nil) //Send resolve alert status to server
        NotificationCenter.default.addObserver(self, selector: #selector(requestUpdate), name: .logUpdate, object: nil) //Update when app opens
        NotificationCenter.default.addObserver(self, selector: #selector(requestUpdateResolve), name: .logUpdateResolve, object: nil) //Ask server to update alerts with resolved status
        NotificationCenter.default.addObserver(self, selector: #selector(determineAlert), name: .receiveNewAlert, object: nil) //When new alert is received from APNs
        NotificationCenter.default.addObserver(self, selector: #selector(sendTokenToServer), name: .deviceToken, object: nil)
        self.navigationItem.navBarImage()

    }

    override func viewWillAppear(_ animated: Bool = true) {
        super.viewWillAppear(animated)
    }
    
    /*@IBAction func toggleSlideMenu(_ sender: Any) {
        // Send notification to toggle slide menu on button tap
        NotificationCenter.default.post(name: .toggleSlideMenu, object: self)
    }*/
    
    // MARK: - MQTT Connection
    
    @objc func mqttConnection() {
        mqttx = CocoaMQTT(clientID: UIDevice.current.identifierForVendor!.uuidString, host: "10.95.21.100", port: 1883)
        mqttx.delegate = self
        mqttx.connect()
    }
    
    // MARK: - MQTT Publish
    
    //Send update to server when user accept alert
    func sendAcceptToServer(alertID: String)
    {
        let alertString = fetchByAlertID(alertID: alertID)
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        mqttx.publish("updateA", withString: alertString + "\t" + (appDelegate?.getGlobalUniqueIdentifierFromKeyChain())!)
    }
    
    @objc func sendTokenToServer(notification: NSNotification)
    {
        print("SENDING TOKEN...")
        //mqttConnection()
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let deviceID = userInfo["deviceID"]! as String
        let token = userInfo["token"]! as String
        
        mqttx.publish("deviceTokens", withString: deviceID + "\t" + token)
    }
    
    //Send update to server when user ....
    @objc func descriptionUpdateServer(notification: NSNotification)
    {
        
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let alertID = userInfo["alertID"]! as String
        
        
        let alertString = fetchByAlertID(alertID: alertID)
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        mqttx.publish("updateD", withString: alertString + "\t" + (appDelegate?.getGlobalUniqueIdentifierFromKeyChain())!)

    }
    
    @objc func resolveUpdateServer(notification: NSNotification) {
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        let alertID = userInfo["alertID"]! as String
        
        
        let alertString = fetchByAlertID(alertID: alertID)
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        mqttx.publish("updateR", withString: alertString + "\t" + (appDelegate?.getGlobalUniqueIdentifierFromKeyChain())!)
    }
    
    //Requesting log update to server
    @objc func requestUpdate() {
        
        mqttx.publish("askForUpdate", withString: "NeedUpdate")
        print("ASKING FOR UPDATE")
        
    }
    
    @objc func requestUpdateResolve() {
        
        mqttx.publish("askForUpdateResolve", withString: "NeedUpdate")
        print("ASKING FOR UPDATE")
        
    }
    
    // MARK: - Process Received Alerts
    
    //Save alerts into Core Data
    func saveAlerts (title: String, icon: String, stringDate: String, timeStamp: String, dateStamp: String, alertID: String, alertStatus: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "NewAlerts",
                                       in: managedContext)!
        
        let alertsType = NSManagedObject(entity: entity, insertInto: managedContext)
        
        alertsType.setValue(alertID, forKey: "alertID")
        alertsType.setValue(title, forKeyPath: "alertTitle")
        alertsType.setValue(alertStatus, forKey: "alertStatus")
        alertsType.setValue(icon, forKey: "alertIcon")
        alertsType.setValue(stringDate, forKey: "stringDate")
        alertsType.setValue(timeStamp, forKey: "timeStamp")
        alertsType.setValue(dateStamp, forKey: "dateStamp")
        alertsType.setValue("Responsible Person", forKey: "responsiblePerson")
        alertsType.setValue("Accept Date", forKey: "acceptDate")
        alertsType.setValue("Accept Time", forKey: "acceptTime")
        alertsType.setValue("", forKey: "alertDescription")
        alertsType.setValue("Resolved Date", forKey: "resolvedDate")
        alertsType.setValue("Resolved Time", forKey: "resolvedTime")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        NotificationCenter.default.post(name: .didReceiveAlert, object: self)
    }
    
    //Determine type of alert and department
    @objc func determineAlert(rawData: NSNotification) {

        let data = rawData.userInfo?["aps"] as! NSDictionary
        
        // Get the properties from the dictionary
        let title = data["title"] ?? "Default Title"
        let date = data["date"] ?? ""
        let time = data["time"] ?? ""
        let icon = data["alertIcon"] ?? ""
        let stringdate = data["stringdate"] ?? ""
        let alertID = data["alertID"] ?? ""
        let acceptTime = data["acceptTime"] ?? ""
        let acceptDate = data["acceptDate"] ?? ""
        let alertStatus = data["alertStatus"] ?? ""
        let resolveDate = data["resolveDate"] ?? ""
        let resolveTime = data["resolveTime"] ?? ""
        let description = data["description"] ?? ""
        let name = data["name"] ?? ""
        
        createAndUpdateAlerts(title: title as! String, date: date as! String, time: time as! String, icon: icon as! String,  stringdate: stringdate as! String, alertID: alertID as! String, acceptTime: acceptTime as! String, acceptDate: acceptDate as! String, alertStatus: alertStatus as! String, resolveDate: resolveDate as! String, resolveTime: resolveTime as! String, description: description as! String, name: name as! String)
        
        //Refresh New Table
        NotificationCenter.default.post(name: .didReceiveAlert, object: nil)
    
    }
    
    func createAndUpdateAlerts(title: String, date: String, time: String, icon: String,  stringdate: String, alertID: String, acceptTime: String, acceptDate: String, alertStatus: String, resolveDate: String, resolveTime: String, description: String, name: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewAlerts")
        let entity =
            NSEntityDescription.entity(forEntityName: "NewAlerts",
                                       in: managedContext)!
        
        var results: [NSManagedObject] = []
        
        fetchRequest.predicate = (NSPredicate(format: "alertID == %@", alertID))
        
        do {
            results = try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("error executing fetch request: \(error)")
        }
            
            //If no match, create new core data
        if results.count == 0 {
            let alertsType = NSManagedObject(entity: entity, insertInto: managedContext)
            
            alertsType.setValue(alertID, forKey: "alertID")
            alertsType.setValue(title, forKey: "alertTitle")
            alertsType.setValue(icon, forKey: "alertIcon")
            alertsType.setValue(stringdate, forKey: "stringDate")
            alertsType.setValue(date, forKey: "dateStamp")
            alertsType.setValue(time, forKey: "timeStamp")
            alertsType.setValue(name, forKey: "responsiblePerson")
            alertsType.setValue(acceptDate, forKey: "acceptDate")
            alertsType.setValue(acceptTime, forKey: "acceptTime")
            alertsType.setValue(description, forKey: "alertDescription")
            alertsType.setValue(resolveDate, forKey: "resolvedDate")
            alertsType.setValue(resolveTime, forKey: "resolvedTime")
            alertsType.setValue(alertStatus, forKey: "alertStatus")
            
            /*if description != "Description" {
                alertsType.setValue(description, forKey: "alertDescription")
            }
             
            else {
                alertsType.setValue("", forKey: "alertDescription")
            }*/
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            NotificationCenter.default.post(name: .didReceiveAlert, object: self)
        }
        // If there is a match, update information in that entity
        else {
            results[0].setValue(name, forKey: "responsiblePerson")
            results[0].setValue(acceptDate, forKey: "acceptDate")
            results[0].setValue(acceptTime, forKey: "acceptTime")
            results[0].setValue(resolveDate, forKey: "resolvedDate")
            results[0].setValue(resolveTime, forKey: "resolvedTime")
            results[0].setValue(alertStatus, forKey: "alertStatus")
            results[0].setValue(stringdate, forKey: "stringDate")
            results[0].setValue(description, forKey: "alertDescription")
            
            /*if description != "Description" {
                results[0].setValue(description, forKey: "alertDescription")
            }
             
            else {
                results[0].setValue("", forKey: "alertDescription")
            }*/
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            } //do catch
        } //else updateCore data
    }
    
    //Called by NewTableVC when a user accept alert. Pull information for specific alertID
    func fetchByAlertID(alertID: String) -> String
    {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return ""
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "NewAlerts")
        
        //Filter for alertStatus 'alertID'
        
        fetchRequest.predicate = NSPredicate(format: "alertID == %@", alertID)
        
        do {
            alertsArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let dateStamp = alertsArray[0].value(forKeyPath: "dateStamp") as! String
        let timeStamp = alertsArray[0].value(forKeyPath: "timeStamp") as! String
        let name = alertsArray[0].value(forKeyPath: "responsiblePerson") as! String
        let acceptDate = alertsArray[0].value(forKeyPath: "acceptDate") as! String
        let acceptTime = alertsArray[0].value(forKeyPath: "acceptTime") as! String
        let description = alertsArray[0].value(forKeyPath: "alertDescription") as! String
        let resolvedDate = alertsArray[0].value(forKeyPath: "resolvedDate") as! String
        let resolvedTime = alertsArray[0].value(forKeyPath: "resolvedTime") as! String
        let alertStatus = alertsArray[0].value(forKeyPath: "alertStatus") as! String
        
        let alert = alertID + "\t" + dateStamp + "\t" + timeStamp + "\t" + name + "\t" + acceptDate + "\t" + acceptTime + "\t" + description + "\t" + resolvedDate + "\t" + resolvedTime + "\t" + alertStatus
        
        return alert
    }
    
    //Update alerts from log saved on server
    func updateWithLog(msg: String) {
        
        var msgData = msg
        
        if msgData != "" {
            //Remove last \n from log file
            msgData.removeLast()
            
            let countLines = msgData.components(separatedBy: "\n").count
            
            let sliceLine = msgData.components(separatedBy: "\n")
            
            //Convert ArraySlice into Array
            let lineArr = Array(sliceLine)
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewAlerts")
            let entity =
                NSEntityDescription.entity(forEntityName: "NewAlerts",
                                           in: managedContext)!
            
            var results: [NSManagedObject] = []
            
            for i in 0...countLines - 1 {
                let alertArr = lineArr[i].components(separatedBy: "\t")
                let logAlertIDArr = alertArr[0] + "\t" + alertArr[1] + "\t" + alertArr[2] + "\t" + alertArr[3]
                fetchRequest.predicate = (NSPredicate(format: "alertID == %@", logAlertIDArr))
                
                do {
                    results = try managedContext.fetch(fetchRequest)
                }
                catch let error as NSError {
                    print("error executing fetch request: \(error)")
                }
            
                //If no match, create new core data
                if results.count == 0 {
                    let alertsType = NSManagedObject(entity: entity, insertInto: managedContext)
                    
                    alertsType.setValue(alertArr[0] + "\t" + alertArr[1] + "\t" + alertArr[2] + "\t" + alertArr[3], forKey: "alertID")
                    alertsType.setValue(alertArr[0] + " " + alertArr[1], forKey: "alertTitle")
                    alertsType.setValue(alertArr[2], forKey: "alertIcon")
                    alertsType.setValue(alertArr[3], forKey: "stringDate")
                    alertsType.setValue(alertArr[4], forKey: "dateStamp")
                    alertsType.setValue(alertArr[5], forKey: "timeStamp")
                    alertsType.setValue(alertArr[6], forKey: "responsiblePerson")
                    alertsType.setValue(alertArr[7], forKey: "acceptDate")
                    alertsType.setValue(alertArr[8], forKey: "acceptTime")
                    alertsType.setValue(alertArr[10], forKey: "resolvedDate")
                    alertsType.setValue(alertArr[11], forKey: "resolvedTime")
                    alertsType.setValue(alertArr[12], forKey: "alertStatus")
                    alertsType.setValue(alertArr[9], forKey: "alertDescription")
                    
                    /*if alertArr[9] != "Description" {
                        alertsType.setValue(alertArr[9], forKey: "alertDescription")
                    }
                  
                    else {
                        alertsType.setValue("", forKey: "alertDescription")
                    }*/
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                    NotificationCenter.default.post(name: .didReceiveAlert, object: self)
                }
                //If there is a match, update information in that entity
                else {
                    results[0].setValue(alertArr[6], forKey: "responsiblePerson")
                    results[0].setValue(alertArr[7], forKey: "acceptDate")
                    results[0].setValue(alertArr[8], forKey: "acceptTime")
                    results[0].setValue(alertArr[10], forKey: "resolvedDate")
                    results[0].setValue(alertArr[11], forKey: "resolvedTime")
                    results[0].setValue(alertArr[12], forKey: "alertStatus")
                    results[0].setValue(alertArr[3], forKey: "stringDate")
                    results[0].setValue(alertArr[9], forKey: "alertDescription")
                    
                    /*if alertArr[9] != "Description" {
                        results[0].setValue(alertArr[9], forKey: "alertDescription")
                    }
                    
                    else {
                        results[0].setValue("", forKey: "alertDescription")
                    }*/
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    } //do catch
                } //else updateCore data
            } //for loop
        }
    } //func update
    
    //Update alerts from log saved on server
    func updateResolveWithLog(msg: String) {
        
        var msgData = msg
        
        if msgData != "" {
            //Remove last \n from log file
            msgData.removeLast()
            
            let countLines = msgData.components(separatedBy: "\n").count
            
            let sliceLine = msgData.components(separatedBy: "\n")
            
            //Convert ArraySlice into Array
            let lineArr = Array(sliceLine)
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewAlerts")
            let entity =
                NSEntityDescription.entity(forEntityName: "NewAlerts",
                                           in: managedContext)!
            
            var results: [NSManagedObject] = []
            
            for i in 0...countLines - 1 {
                let alertArr = lineArr[i].components(separatedBy: "\t")
                let logAlertIDArr = alertArr[0] + "\t" + alertArr[1] + "\t" + alertArr[2] + "\t" + alertArr[3]
                fetchRequest.predicate = (NSPredicate(format: "alertID == %@", logAlertIDArr))
                
                do {
                    results = try managedContext.fetch(fetchRequest)
                }
                catch let error as NSError {
                    print("error executing fetch request: \(error)")
                }
                
                //If no match, create new core data
                if results.count == 0 {
                    let alertsType = NSManagedObject(entity: entity, insertInto: managedContext)
                    
                    alertsType.setValue(alertArr[0] + "\t" + alertArr[1] + "\t" + alertArr[2] + "\t" + alertArr[3], forKey: "alertID")
                    alertsType.setValue(alertArr[0] + " " + alertArr[1], forKey: "alertTitle")
                    alertsType.setValue(alertArr[2], forKey: "alertIcon")
                    alertsType.setValue(alertArr[3], forKey: "stringDate")
                    alertsType.setValue(alertArr[4], forKey: "dateStamp")
                    alertsType.setValue(alertArr[5], forKey: "timeStamp")
                    alertsType.setValue(alertArr[6], forKey: "responsiblePerson")
                    alertsType.setValue(alertArr[7], forKey: "acceptDate")
                    alertsType.setValue(alertArr[8], forKey: "acceptTime")
                    alertsType.setValue(alertArr[10], forKey: "resolvedDate")
                    alertsType.setValue(alertArr[11], forKey: "resolvedTime")
                    alertsType.setValue(alertArr[12], forKey: "alertStatus")
                    alertsType.setValue(alertArr[9], forKey: "alertDescription")
                    
                    /*if alertArr[9] != "Description" {
                        alertsType.setValue(alertArr[9], forKey: "alertDescription")
                    }
                        
                    else {
                        alertsType.setValue("", forKey: "alertDescription")
                    }
                    */
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                    NotificationCenter.default.post(name: .didReceiveAlert, object: self)
                }
                    //If there is a match, update information in that entity
                else {
                    results[0].setValue(alertArr[6], forKey: "responsiblePerson")
                    results[0].setValue(alertArr[7], forKey: "acceptDate")
                    results[0].setValue(alertArr[8], forKey: "acceptTime")
                    results[0].setValue(alertArr[10], forKey: "resolvedDate")
                    results[0].setValue(alertArr[11], forKey: "resolvedTime")
                    results[0].setValue(alertArr[12], forKey: "alertStatus")
                    results[0].setValue(alertArr[3], forKey: "stringDate")
                    results[0].setValue(alertArr[9], forKey: "alertDescription")
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    } //do catch
                } //else updateCore data
            } //for loop
        }
    } //func update

}

// MARK: - MQTT Extensions
extension TabBar: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        debugPrint("Subscribed")
    }
    

    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        
    }
    
    //On receive message
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {

        if let msgString = message.string {
            
            //If server send back log update
            if message.topic == "logUpdate"  {
                print("LOG INFO IS " + msgString)
                updateWithLog(msg: msgString)
            }

            else if message.topic == "logUpdateResolve" {
                print(msgString)
                updateResolveWithLog(msg: msgString)
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        debugPrint("Connected")
        mqttx.subscribe("newAlert")
        mqttx.subscribe("logUpdate")
        mqttx.subscribe("logUpdateResolve")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        debugPrint("Published Message")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("RECEIVING PING")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        debugPrint("Disconnected")
        self.mqttConnection()
    }
    
    func _console(_ info: String) {
    }
    
}

