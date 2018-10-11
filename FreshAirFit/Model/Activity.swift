//
//  Activity.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UserNotifications

class Activity: NSObject, Codable {
    var activityDescription = ""
    var lowTemp = ""
    var highTemp = ""
    var shouldNotify = false
    var notifyTime = Date()
    var notifyText = ""  // need to make this something like "tomorrow will be 95. might be a nice day for a swim" and add weather info
    var activityID: Int
    
    override init() {
        activityID = Activity.nextActivityID()
        super.init()
    }
    
    class func nextActivityID() -> Int {
        let userDefaults = UserDefaults.standard
        let activityID = userDefaults.integer(forKey: "ActivityID")
        userDefaults.set(activityID + 1, forKey: "ActivityID")
        userDefaults.synchronize()
        return activityID
    }
    
    func scheduleNotification() {
        removeNotification()
        if shouldNotify {
            let content = UNMutableNotificationContent()
            content.title = "Just thought you'd like to know..."
            content.body = notifyText
            content.sound = UNNotificationSound.default
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.hour, .minute], from: notifyTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "\(activityID)", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Scheduled: \(request) for activityID: \(activityID)")
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(activityID)"])
    }
    
    deinit {
        removeNotification()
    }
}
