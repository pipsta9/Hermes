//
//  SlideTableVC.swift
//  MQTTDemo
//
//  Created by Tim on 8/10/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit

class SlideTableVC: UITableViewController, SlideCellDelegate {

    var topics: [Topic]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register nib file
        tableView.register(UINib(nibName: "SlideCell", bundle: nil), forCellReuseIdentifier: "SlideCell")

        // Get the topic array from user defaults
        let defaults = UserDefaults.standard
        let topicsData = defaults.object(forKey: "Topics") as! Data
        topics = NSKeyedUnarchiver.unarchiveObject(with: topicsData) as? [Topic]
        
    }
    
    // Delegate Method
    func saveTopicChange() {
        
        // Save the topics array to user defaults
        let defaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: topics)
        defaults.set(data, forKey: "Topics")
        
        // Post notification to update MQTT subscriptions
        NotificationCenter.default.post(name: .updateSubs, object: self)
    }
    
    @IBAction func removeAllSubs(_ sender: Any) {
        // Loop over the topics and unsubscribe to all
        for topic in topics {
            topic.subscribed = false
        }
        self.saveTopicChange()
        self.tableView.reloadData()
    }
    
    @IBAction func selectAllSubs(_ sender: Any) {
        // Loop over the topics and subscribe to all
        for topic in topics {
            topic.subscribed = true
        }
        self.saveTopicChange()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Departments"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return topics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SlideCell", for: indexPath) as! SlideCell
        
        // Get the topic struct
        let topic = topics[indexPath.row]
        
        // Set the cell properties
        cell.topic = topic
        cell.label.text = topic.name
        cell.subSwitch.isOn = topic.subscribed
        cell.delegate = self
        
        return cell
    }

}
