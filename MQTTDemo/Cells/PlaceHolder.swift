//
//  PlaceHolderCell.swift
//  
//
//  Created by Apipon Siripaisan on 8/15/18.
//

import UIKit

class PlaceHolder: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //placeHolderText.layer.borderWidth = 0.5
        //placeHolderText.layer.borderColor = UIColor.black.cgColor
        //placeHolderText.layer.cornerRadius = 5
        
        // Initialization code
        
    }

    @IBOutlet var placeHolderText: UITextView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
