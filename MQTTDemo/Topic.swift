//
//  Topic.swift
//  MQTTDemo
//
//  Created by Tim on 8/16/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import Foundation

class Topic: NSObject, NSCoding {
    var name: String
    var subscribed: Bool
    
    required init(name: String, subscribed: Bool) {
        self.name = name
        self.subscribed = subscribed
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        subscribed = aDecoder.decodeBool(forKey: "subscribed")
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(subscribed, forKey: "subscribed")
    }
}
