//
//  ResolvedCell.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 8/9/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit

class ResolvedCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var resolvedDate: UILabel!
    
    @IBOutlet weak var resolvedTime: UILabel!
    @IBOutlet weak var responsiblePerson: UILabel!
    
    
    @IBOutlet weak var alertIcon: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
