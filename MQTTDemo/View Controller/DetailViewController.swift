//
//  DetailViewController.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 8/5/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit
import CoreData


class DetailViewController: UITableViewController, UITextViewDelegate {
    
    var alert: NewAlerts!
    
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var receivedDate: UILabel!
    @IBOutlet weak var receivedTime: UILabel!
    @IBOutlet weak var responsiblePerson: UILabel!
    @IBOutlet weak var acceptDate: UILabel!
    @IBOutlet weak var acceptTime: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBAction func resolveButton(_ sender: Any) {
        if descriptionText.text != "" {
            alert.alertDescription = descriptionText.text
        }
        
        else {
            alert.alertDescription = ""
        }
        
        alert.alertStatus = "resolved"
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let resolvedDate = formatter.string(from: date)
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let resolvedTime = formatter.string(from: date)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stringDate = formatter.string(from: date)
        
        alert.stringDate = stringDate
        alert.resolvedDate = resolvedDate
        alert.resolvedTime = resolvedTime
        
        saveAlerts()
        
        
        NotificationCenter.default.post(name: .resolveUpdate, object: nil, userInfo: ["alertID": alert.alertID!])

        NotificationCenter.default.post(name: .changeToResolve, object: nil)
            
        navigationController?.popViewController(animated: true)
        
    }
    
    
    func doUpdate () {
        alert.alertDescription = descriptionText.text
        
        saveAlerts()
        
        let alertController = UIAlertController(title: "Saved!", message: "Description successfully saved", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        
        NotificationCenter.default.post(name: .descriptionUpdate, object: nil, userInfo: ["alertID": alert.alertID!])
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionText.delegate = self
        descriptionText.returnKeyType = UIReturnKeyType.done
        
        switch alert.alertIcon {
        case "1":
            icon.image = #imageLiteral(resourceName: "critical")
        case "2":
            icon.image = #imageLiteral(resourceName: "safety")
        case "3":
            icon.image = #imageLiteral(resourceName: "stoppage")
        default:
            break
        }
        
        // Set the label text
        location.text = alert.alertTitle
        receivedDate.text = alert.dateStamp
        receivedTime.text = alert.timeStamp
        responsiblePerson.text = alert.responsiblePerson
        acceptDate.text = alert.acceptDate
        acceptTime.text = alert.acceptTime
        descriptionText.text = alert.alertDescription
        
        // Format the description field
        descriptionText.layer.borderColor = UIColor(displayP3Red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0).cgColor
        descriptionText.layer.borderWidth = 1
        descriptionText.layer.cornerRadius = 5
        
        
        

        // Create a gesture recognizer for dismissing the keyboard on tap outside the textView (See Extensions file)
        //self.hideKeyboard()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            doUpdate()
            return false
        }
        return true
    }

    
    func saveAlerts () {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }

    
    
}

