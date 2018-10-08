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
    var lowTemp: Int
    var highTemp: Int
    
    init(description: String, weatherIcon: String, lowTemp: Int, highTemp: Int) {
        self.description = description
        self.weatherIcon = weatherIcon
        self.lowTemp = lowTemp
        self.highTemp = highTemp
    }
}
