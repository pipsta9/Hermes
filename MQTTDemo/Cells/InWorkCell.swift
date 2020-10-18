//
//  InWorkCell.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 8/4/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit

class InWorkCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBOutlet weak var alertIcon: UIImageView!
    
    @IBOutlet weak var alertTitle: UILabel!
    
    @IBOutlet weak var acceptDate: UILabel!
    
    @IBOutlet weak var acceptTime: UILabel!
    
    @IBOutlet weak var responsiblePerson: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
