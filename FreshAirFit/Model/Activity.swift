//
//  Activity.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UserNotifications

class Activity {
    var description = "Add a description for your activity..."
    var lowTemp = ""
    var highTemp = ""
    var shouldNotify = false
    var notifyTime = Date()
    var notifyText = ""
    
    func scheduleNotification() {  // HQ Daily.swift
        removeNotification()
        if shouldNotify {
            let content = UNMutableNotificationContent()
            content.title = "Just thought you'd like to know..."
        }
    }
    
    func removeNotification() {  // HQ Daily.swift
        
    }
}
