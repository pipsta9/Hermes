//
//  TopVC.swift
//  MQTTDemo
//
//  Created by Tim on 8/10/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit

class TopVC: UIViewController {

    @IBOutlet weak var slideConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    
    var open = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register for slide menu notification
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSlideMenu), name: .toggleSlideMenu, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If the slide menu is open and the touch is in the main view, hide the slide menu
        let view = touches.first?.view
        if view == mainView && open == true {
            self.toggleSlideMenu()
        }
    }
    
    @objc func toggleSlideMenu() {
        if open {
            slideConstraint.constant = -240
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
                // Turn on user interaction for all subviews of the main view
                for view in self.mainView.subviews {
                    view.isUserInteractionEnabled = true
                }
            }
            open = false
        } else {
            slideConstraint.constant = 0
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
                // Turn off user interaction for all subviews of the main view
                // This allows the container to receive all touch events
                for view in self.mainView.subviews {
                    print(view)
                    view.isUserInteractionEnabled = false
                }
            }
            open = true
        }
    }

}
