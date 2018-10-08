//
//  Activity.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class Activity {
    var description: String
    var weatherIcon: String
    var lowTemp: String
    var highTemp: String
    var shouldRemind: Bool
    
    init() {
        self.description = "Add a description for your activity..."
        self.weatherIcon = "defaultImage"
        self.lowTemp = "..."
        self.highTemp = "..."
        self.shouldRemind = false
    }
}
