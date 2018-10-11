//
//  WeatherCondition.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/10/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class WeatherCondition {
    var weatherIcon: String
    var weatherConditionDescription: String
    var isChecked = false
    
    init(weatherIcon: String, weatherConditionDescription: String) {
        self.weatherIcon = weatherIcon
        self.weatherConditionDescription = weatherConditionDescription
    }
}
