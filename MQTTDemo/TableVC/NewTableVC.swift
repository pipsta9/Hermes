//
//  NewAlertsVC.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 7/29/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit
import CoreData
import CocoaMQTT


class NewTableVC: UITableViewController {
    
    var alertsArray: [NSManagedObject] = []
    var alerts: NewAlerts!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Register nib file for cell formatting
        tableView.register(UINib(nibName: "PlaceHolder", bundle: nil), forCellReuseIdentifier: "PlaceHolder")
        tableView.register(UINib(nibName: "AlertCell", bundle: nil), forCellReuseIdentifier: "AlertCell")
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        NotificationCenter.default.addObserver(self, selector: #selector(clear), name: .didReceiveAlert, object: nil)
      
    }
    
    override func viewWillAppear(_ animated: Bool = true) {
        
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        refreshTable()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if alertsArray.count == 0 {
            return 1
        } else {
            return alertsArray.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if alertsArray.count == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceHolder", for: indexPath) as! PlaceHolder
            cell.placeHolderText.text = """
                                        No new alerts
                                        New alerts will appear here once button is pressed
                                        """
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        
        } else {
            
            let alerts = alertsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
            
            cell.alertTitle.text = (alerts.value(forKeyPath: "alertTitle") as? String)
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
            
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Create pop up with name input field
        let alertController = UIAlertController(title: "Enter Name", message: "Who will attend to this issue?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Accept", style: .default) { (_) in
            

            let name = alertController.textFields![0].text!
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let acceptDate = formatter.string(from: date)
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            let acceptTime = formatter.string(from: date)
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let stringDate = formatter.string(from: date)
            
            let rowNum = indexPath.row

            
            self.acceptAlert(name: name, acceptDate: acceptDate, acceptTime: acceptTime, rowNum: rowNum, stringDate: stringDate)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.autocapitalizationType = UITextAutocapitalizationType.words
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
    
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    //referesh table called by local notification
    @objc func refreshTable() {
        
        
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "NewAlerts")
        
        //Filter for alertStatus 'new'
        fetchRequest.predicate = NSPredicate(format: "alertStatus == 'new'")
        
        
        let sort = NSSortDescriptor(key: "stringDate", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        
        
        do {
            alertsArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        tableView.reloadData()
 
    }

    
    //Once a user accept the alert
    func acceptAlert (name: String, acceptDate: String, acceptTime: String, rowNum: Int, stringDate: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let alert = alertsArray[rowNum]
        
        alert.setValue("inwork", forKey: "alertStatus")
        alert.setValue(name, forKey: "responsiblePerson")
        alert.setValue(acceptDate, forKey: "acceptDate")
        alert.setValue(acceptTime, forKey: "acceptTime")
        alert.setValue(stringDate, forKey: "stringDate")
        
        let alertID = alert.value(forKey: "alertID") as! String

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
        (self.tabBarController as? TabBar)?.sendAcceptToServer(alertID: alertID)
        
        self.tabBarController?.selectedIndex = 1
        
    }
    
    @objc func clear() {
        var viewControllers = self.navigationController?.viewControllers
        let firstViewCtr = viewControllers?.first
        viewControllers?.removeAll()
        viewControllers?.insert(firstViewCtr!, at: 0)
        self.navigationController?.viewControllers = viewControllers!
        refreshTable()
    }
    
    
}
