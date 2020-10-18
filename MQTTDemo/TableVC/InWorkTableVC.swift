//
//  InWorkTableVC.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 8/2/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit
import CoreData

class InWorkTableVC: UITableViewController {

    var alertsArray: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        tableView.register(UINib(nibName: "PlaceHolder", bundle: nil), forCellReuseIdentifier: "PlaceHolder")
        tableView.register(UINib(nibName: "InWorkCell", bundle: nil), forCellReuseIdentifier: "InWorkCell")
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: .didReceiveAlert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToResolve), name: .changeToResolve, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool = true) {
        
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        refreshTable()
        
    }
    
    @objc func changeToResolve() {
        self.tabBarController?.selectedIndex = 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if alertsArray.count == 0 {
            return 1
        } else{
        return alertsArray.count
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if alertsArray.count == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceHolder", for: indexPath) as! PlaceHolder
            cell.placeHolderText.text = """
                                        No in work alerts
                                        In work alerts will appear here once it is accepted
                                        """
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        }
        else {
            let alerts = alertsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "InWorkCell", for: indexPath) as! InWorkCell
            
            cell.alertTitle.text = (alerts.value(forKeyPath: "alertTitle") as? String)
            cell.responsiblePerson.text = "Accepted by: " + (alerts.value(forKeyPath: "responsiblePerson") as? String)!
            cell.acceptDate.text = (alerts.value(forKeyPath: "acceptDate") as? String)
            cell.acceptTime.text = (alerts.value(forKeyPath: "acceptTime") as? String)
            
            
            cell.tintColor = UIColor.blue
            if alerts.value(forKeyPath: "alertDescription") as? String != "" {
                cell.accessoryType = UITableViewCellAccessoryType.detailDisclosureButton
                
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            
            
            switch alerts.value(forKeyPath: "alertIcon") as? String {
                case "1":
                    cell.alertIcon.image = #imageLiteral(resourceName: "critical")
                case "2":
                    cell.alertIcon.image = #imageLiteral(resourceName: "safety")
                case "3":
                    cell.alertIcon.image = #imageLiteral(resourceName: "stoppage")
                default:
                    break
            }
            
            return cell
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let destination = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        //Cast selected alert array to detailviewcontroller
        destination.alert = alertsArray[indexPath.row] as? NewAlerts
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func refreshTable() {
        

        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        

        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "NewAlerts")
        
        //Filter for alertStatus 'inwork'
        fetchRequest.predicate = NSPredicate(format: "alertStatus == 'inwork'")
        
        let sort = NSSortDescriptor(key: "stringDate", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            alertsArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
        
    }

}
