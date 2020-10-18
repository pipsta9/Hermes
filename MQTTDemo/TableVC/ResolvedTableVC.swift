//
//  ResolvedTableVC.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 8/2/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit
import CoreData

class ResolvedTableVC: UITableViewController, UIPickerViewDelegate {
    
    var alertsArray: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        tableView.register(UINib(nibName: "PlaceHolder", bundle: nil), forCellReuseIdentifier: "PlaceHolder")
        tableView.register(UINib(nibName: "ResolvedCell", bundle: nil), forCellReuseIdentifier: "ResolvedCell")
        tableView.register(UINib(nibName: "Filter", bundle: nil), forCellReuseIdentifier: "Filter")
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: .didReceiveAlert, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool = true) {
        super.viewWillAppear(animated)
        refreshTable()
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Refresh"), style: .plain, target: self, action: #selector(updateResolve))
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(filterAlert))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
  
    }

    /*override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 35
        }
        else {
            return 80
        }
    }*/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if alertsArray.count == 0 {
            return 1
            
        }else {

        return alertsArray.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Filter") as! Filter
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
        
        else  {
            
        }*/
            if alertsArray.count == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceHolder", for: indexPath) as! PlaceHolder
                cell.placeHolderText.text = """
                                            No resolved alerts
                                            Resolved alerts will appear here once it is resolved
                                            """
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                return cell
                
            } else {
            let alerts = alertsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResolvedCell", for: indexPath) as! ResolvedCell
            
            cell.alertTitle.text = (alerts.value(forKeyPath: "alertTitle") as? String)
            cell.responsiblePerson.text = "Resolved by: " + (alerts.value(forKeyPath: "responsiblePerson") as? String)!
            cell.resolvedDate.text = (alerts.value(forKeyPath: "dateStamp") as? String)
            cell.resolvedTime.text = (alerts.value(forKeyPath: "timeStamp") as? String)
                
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
            
            let destination = storyboard.instantiateViewController(withIdentifier: "ResolvedDetailView") as! ResolvedDetailView
            
            destination.alert = alertsArray[indexPath.row] as? NewAlerts
            
            navigationController?.pushViewController(destination, animated: true)
        
        
    }
    
    @objc func updateResolve() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let resolvedPredicate = NSPredicate(format: "alertStatus == 'resolved'")
        
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "NewAlerts")
        deleteFetch.predicate = resolvedPredicate
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }

        
        let alertController = UIAlertController(title: "Synchronized", message: "Resolved alerts synched with server", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        
        NotificationCenter.default.post(name: .logUpdateResolve, object: nil)
        
        self.present(alertController, animated: true, completion: nil)
        
        refreshTable()
        
        
    }
    
    @objc func filterAlert() {
        
     
        let alertController = UIAlertController(title: "\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let margin:CGFloat = 10.0
        let rect = CGRect(x: margin, y: margin, width: 335/*alertController.view.bounds.size.width - margin * 4.0*/, height: 120)
        let customView = MonthYearPickerView(frame: rect)

        alertController.view.addSubview(customView)
        
        let confirmAction = UIAlertAction(title: "Apply", style: .default) { (_) in
            
            self.determineMonthandYear(month: customView.month, year: customView.year)
  
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func determineMonthandYear(month: Int, year: Int) {
        
        
        let monthName = String(DateFormatter().monthSymbols[month - 1].prefix(3))
        
        let year = String(year)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "NewAlerts")
        
        //Filter for alertStatus 'resolved'
        //fetchRequest.predicate =

        let resolvedPredicate = NSPredicate(format: "alertStatus == 'resolved'")
        let monthPredicate = NSPredicate(format: "dateStamp contains[c] %@", monthName)
        let yearPredicate = NSPredicate(format: "dateStamp contains[c] %@", year)
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [resolvedPredicate, monthPredicate, yearPredicate])
        
        fetchRequest.predicate = andPredicate
        
        let sort = NSSortDescriptor(key: "stringDate", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        
        do {
            alertsArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
        
    }
 

    @objc func refreshTable() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "NewAlerts")
        
        //Filter for alertStatus 'resolved'
        fetchRequest.predicate = NSPredicate(format: "alertStatus == 'resolved'")
        
    
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


