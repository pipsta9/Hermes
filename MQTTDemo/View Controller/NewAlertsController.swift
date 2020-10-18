//
//  ViewController.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 3/24/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit
import CocoaMQTT
import CoreData

class NewAlertsController: UIViewController {

    @IBAction func safetyMes(_ sender: Any) {
        determineAlert(msg: "B8 Assembly 2")
    }
    
    @IBAction func sendMes(_ sender: Any) {
        determineAlert(msg: "B8 Paint 1")
    }
    

    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func deleteAlerts(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "NewAlerts")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
        
        refreshTable()
        tableView.reloadData()
        viewWillAppear()

    }
    
    var alertsArray: [NSManagedObject] = []
    
    
    
    //Instantiate CocoaMQTT as mqttClient
    var mqttx: CocoaMQTT!
    var text: CocoaMQTTMessage!
    
    
    
    //Executes after loading the view for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        mqttx = CocoaMQTT(clientID: "iOS Device", host: "172.20.10.6", port: 1883)
        mqttx.delegate = self
        mqttx.connect()
        
        tableView.rowHeight = 80
        
        tableView.register(UINib(nibName: "AlertCell", bundle: nil), forCellReuseIdentifier: "AlertCell")
        
        

        
        
    }

    override func viewWillAppear(_ animated: Bool = true) {
        
        super.viewWillAppear(animated)
        refreshTable()

    }
    
    func refreshTable() {
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "NewAlerts")
        
        
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]

        
        //3
        
        do {
            alertsArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
        
    }
    
    
    @IBAction func mess(_ sender: UIButton) {
        mqttx.publish("iOSconfirmation", withString: "Message received on iOS")
    }
    
    //Save alerts into Core Data
    func saveAlerts (title: String, responsible: String, icon: String, date: Date, timeStamp: String, dateStamp: String) {
    
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
        return
        }
    
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "NewAlerts",
                                       in: managedContext)!
        
        let alertsType = NSManagedObject(entity: entity, insertInto: managedContext)
        
        
        // 3
        alertsType.setValue(title, forKeyPath: "alertTitle")
        alertsType.setValue(responsible, forKey: "alertDescription")
        alertsType.setValue(icon, forKey: "alertIcon")
        alertsType.setValue(date, forKey: "date")
        alertsType.setValue(timeStamp, forKey: "timeStamp")
        alertsType.setValue(dateStamp, forKey: "dateStamp")
    

        
        // 4
        do {
            try managedContext.save()
            alertsArray.append(alertsType)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    //Determine type of alert and department
    func determineAlert(msg: String) {
        let msgArr = msg.components(separatedBy: " ")
        
        var title: String? = nil
        var icon: String? = nil, responsible: String? = nil
        let determine: String = msgArr[1]
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateStamp = formatter.string(from: date)
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeStamp = formatter.string(from: date)
        //let calendar = Calendar.current
        //let currentDate = NSDate()
        //let hour = calendar.component(.hour, from: date)
        //let minutes = calendar.component(.minute, from: date)
        
        
        title = msgArr[0] + " " + msgArr[1]
        icon = msgArr[2]
        
        switch determine {
            case "Paint":
            responsible = "Roland Abreu"
            case "Assembly":
            responsible = "Eddy Welton"
        default:
            break
            
        }
        
        let timeArr = timeStamp.components(separatedBy: " ")
        print(timeArr[0])
        print(dateStamp)
        
        
        saveAlerts(title: title!, responsible: responsible!, icon: icon!, date: date, timeStamp: timeStamp, dateStamp: dateStamp)
        refreshTable()
    }
    
    
    
    
}
extension NewAlertsController: CocoaMQTTDelegate, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let alerts = alertsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
        
        cell.alertTitle.text = (alerts.value(forKeyPath: "alertTitle") as? String)
        cell.alertText.text = (alerts.value(forKeyPath: "alertDescription") as? String)
        cell.alertDate.text = (alerts.value(forKeyPath: "dateStamp") as? String)
        cell.alertTime.text = (alerts.value(forKeyPath: "timeStamp") as? String)

        
        switch alerts.value(forKeyPath: "alertIcon") as? String {
            case "1":
                cell.alertImage.image = #imageLiteral(resourceName: "critical")
            case "2":
                cell.alertImage.image = #imageLiteral(resourceName: "safety")
            case "3":
                cell.alertImage.image = #imageLiteral(resourceName: "stoppage")
            default:
                break
            
        }
            

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "DetailViewController") //as! DetailView
        navigationController?.pushViewController(destination, animated: true)
        print("row clicked")
        
        /*let detailView = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailView.alert = alertsArray[indexPath.row] as! NewAlerts
        
        self.navigationController!.pushViewController(detailView, animated: true)*/

        
    }
    // These two methods are all we care about for now
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {

    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        if let msgString = message.string {
            determineAlert(msg: msgString)
        }
    }
    
    // Other required methods for CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        debugPrint("Connected")
        mqttx.subscribe("notificationAlert")
        //subscribe()
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        debugPrint("Published Message")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        debugPrint("Subscribed")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        debugPrint("Disconnected")
    }
    
    func _console(_ info: String) {
    }
}


