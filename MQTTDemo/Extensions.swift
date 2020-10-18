//
//  Extensions.swift
//  MQTTDemo
//
//  Created by Tim on 8/16/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import Foundation
import UIKit
import CocoaMQTT
import CoreData

extension UIViewController {
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UINavigationItem {
    
    func navBarImage() {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "topBannerLogo")
        
        self.titleView = imageView
    }
}

extension String {
    
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = formatter.date(from: self)
        return date!
    }
}

extension Date {
    
    func toStr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let str = formatter.string(from: self)
        return str
    }
}



