//
//  SlideCell.swift
//  MQTTDemo
//
//  Created by Tim on 8/10/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit

class SlideCell: UITableViewCell {

    var topic: Topic!
    weak var delegate: SlideCellDelegate?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func switchValueChanged(_ sender: Any) {
        if subSwitch.isOn {
            topic.subscribed = true
        } else {
            topic.subscribed = false
        }
        delegate?.saveTopicChange()
    }
    
}

protocol SlideCellDelegate: AnyObject {
    func saveTopicChange()
}
