//
//  ResolvedDetailView.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 8/9/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit

class ResolvedDetailView: UITableViewController {

    var alert: NewAlerts!
    
    @IBOutlet weak var alertIcon: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var receiveDate: UILabel!
    @IBOutlet weak var receiveTime: UILabel!
    @IBOutlet weak var responsiblePerson: UILabel!
    @IBOutlet weak var acceptDate: UILabel!
    @IBOutlet weak var acceptTime: UILabel!
    @IBOutlet weak var textDescription: UITextView!
    @IBOutlet weak var resolveDate: UILabel!
    @IBOutlet weak var resolveTime: UILabel!
    @IBOutlet weak var descriptionCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch alert.alertIcon {
        case "1":
            alertIcon.image = #imageLiteral(resourceName: "critical")
        case "2":
            alertIcon.image = #imageLiteral(resourceName: "safety")
        case "3":
            alertIcon.image = #imageLiteral(resourceName: "stoppage")
        default:
            break
        }
        location.text = alert.alertTitle
        receiveDate.text = alert.dateStamp
        receiveTime .text = alert.timeStamp
        responsiblePerson.text = alert.responsiblePerson
        acceptDate.text = alert.acceptDate
        acceptTime.text = alert.acceptTime
        textDescription.text = alert.alertDescription
        resolveDate.text = alert.resolvedDate
        resolveTime.text = alert.resolvedTime
        
        // Format the description view
        textDescription.layer.borderColor = UIColor(displayP3Red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0).cgColor
        textDescription.layer.borderWidth = 1
        textDescription.layer.cornerRadius = 5
        
        // Size the description view to match it's content
        
         /*textDescription.translatesAutoresizingMaskIntoConstraints = true
        let width = textDescription.layer.frame.size.width
        textDescription.sizeToFit()
        textDescription.layer.frame.size.width = width*/
         
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    /*override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 3 {
            return UITableViewAutomaticDimension
        } else if indexPath.section == 0 {
            return 90
        } else {
            return 43.5
        }
    }*/
 
}
