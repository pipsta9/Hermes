//
//  AlertCell.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 7/23/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit

class AlertCell: UITableViewCell {

    @IBOutlet weak var alertImage: UIImageView!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertDate: UILabel!
    @IBOutlet weak var alertTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
