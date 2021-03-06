//
//  ViewController.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
}

class ActivitiesViewController: UITableViewController, ActivityDetailsViewControllerDelegate, CLLocationManagerDelegate {
    //change last bit of weatherURL from "weather" to "forecast" to get 5 day forecast
    let weatherURL = "http://api.openweathermap.org/data/2.5/forecast"
    let appID = "63b1578537bf98519c346221f7f4efda"
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
//    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var activities = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "blueSkies"))
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        handleFirstTime()
        loadActivities()  //do I still need this? check book
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    //MARK: - TableView Delegate Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ActivityTableViewCell
        cell.activityDescriptionLabel?.text = activities[indexPath.row].activityDescription
        
        let lowTemp = activities[indexPath.row].lowTemp
        let highTemp = activities[indexPath.row].highTemp
        
        var conditionsLabelText = "Temp: "
        if !lowTemp.isEmpty && highTemp.isEmpty {
            conditionsLabelText += ">\(lowTemp)°"
        } else if lowTemp.isEmpty && !highTemp.isEmpty {
            conditionsLabelText += "<\(highTemp)°"
        } else if !lowTemp.isEmpty && !highTemp.isEmpty {
            conditionsLabelText += "\(lowTemp)° - \(highTemp)°"
        }
        cell.conditionsLabel?.text = conditionsLabelText
        
        var weatherLabelText = "Weather: "
        var firstLoop = true
        for condition in activities[indexPath.row].activityWeatherConditions {
            if firstLoop == true {
                weatherLabelText += condition
                firstLoop = false
            } else if firstLoop == false {
                weatherLabelText += ", \(condition)"
            }
        }
        cell.weatherLabel?.text = weatherLabelText
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        activities.remove(at: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        saveActivities()
    }
    
    //MARK: - ActivityDetailsViewControllerDelegate Functions
    func activityDetailsViewControllerDidCancel(_ controller: ActivityDetailsViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func activityDetailsViewController(_ controller: ActivityDetailsViewController, didFinishAdding activity: Activity) {
        let newRowIndex = activities.count
        activities.append(activity)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        navigationController?.popViewController(animated: true)
        saveActivities()
    }
    
    func activityDetailsViewController(_ controller: ActivityDetailsViewController, didFinishEditing activity: Activity) {
        if let index = activities.index(of: activity) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ActivityTableViewCell {
                cell.activityDescriptionLabel.text = activity.activityDescription
                cell.conditionsLabel.text = "Temp. range: \(activity.lowTemp)° - \(activity.highTemp)°"
            }
        }
        navigationController?.popViewController(animated: true)
        saveActivities()
    }
    
    //MARK: - Other Functions
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Activities.plist")
    }
    
    func saveActivities() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(activities)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding Activities.")
        }
    }
    
    func loadActivities() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                activities = try decoder.decode([Activity].self, from: data)
            } catch {
                print("Error decoding Activities.")
            }
        }
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let launchedBefore = userDefaults.bool(forKey: "launchedBefore")
        
        if launchedBefore == false {
            userDefaults.set(true, forKey: "launchedBefore")
            userDefaults.synchronize()
            
            let title = "Welcome to Fresh Air Fit!"
            let message = """

• Click the + button at the top right to add a new Activity.

• Set temperature ranges and weather conditions for your activity.

• Receive a notification the day before so you can get more outdoor exercise!
"""
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true)
        }
        print("launchedBefore = \(launchedBefore)")
    }
    
    //MARK: - LocationManager Delegate Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let parameters = ["lat": latitude, "lon": longitude, "appid": appID]
            
            getWeatherData(url: weatherURL, parameters: parameters)
            print("longitude = \(longitude), latitude = \(latitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    //MARK: - Networking
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success! Got the weather data.")
                let weatherJSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Error: \(response.result.error!)")
            }
        }
    }
    
    func updateWeatherData(json: JSON) {
        //["list"][5] is the weather for noon of the next calendar day
        let tempResult = json["list"][5]["main"]["temp"].doubleValue
        
        //convert kelvin to fahrenheit:
        weatherData.temperature = Int(9/5 * (tempResult - 273) + 32)
        weatherData.condition = json["list"][5]["weather"][0]["description"].stringValue
        weatherData.date = json["list"][5]["dt_txt"].stringValue
    
//        print(json)
    }
    
    
//    //Background Functions
//    func registerBackgroundTask() {
//        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
//            self?.endBackgroundTask()
//        }
//        assert(backgroundTask != .invalid)
//    }
//
//    func endBackgroundTask() {
//        print("Background task ended.")
//        UIApplication.shared.endBackgroundTask(backgroundTask)
//        backgroundTask = .invalid
//    }
    
    
    #warning("this func is new and not sure it works")
    func scheduleNotification() {
        print("scheduleNotification called")
        locationManager.startUpdatingLocation()
        
        let locations = [CLLocation]()
        let location = locations.last!
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let parameters = ["lat": latitude, "lon": longitude, "appid": appID]
            
            getWeatherData(url: weatherURL, parameters: parameters)
            print("longitude = \(longitude), latitude = \(latitude)")
        }
        
        for activity in activities {
            switch activity.shouldNotify {
            case !activity.lowTemp.isEmpty && weatherData.temperature > Int(activity.lowTemp)! && activity.highTemp.isEmpty:
                if activity.activityWeatherConditions.contains(weatherData.condition) {
                    activity.shouldNotify = true
                    print(">lowTemp true")
                } else {
                    activity.shouldNotify = false
                    print(">lowTemp false")
                }
            case !activity.highTemp.isEmpty && weatherData.temperature < Int(activity.highTemp)! && activity.lowTemp.isEmpty:
                if activity.activityWeatherConditions.contains(weatherData.condition) {
                    activity.shouldNotify = true
                    print("<highTemp true")
                } else {
                    activity.shouldNotify = false
                    print("<highTemp false")
                }
            case !activity.highTemp.isEmpty && !activity.lowTemp.isEmpty && Int(activity.lowTemp)!...Int(activity.highTemp)! ~= weatherData.temperature:
                if activity.activityWeatherConditions.contains(weatherData.condition) {
                    activity.shouldNotify = true
                    print("in range true")
                } else {
                    activity.shouldNotify = false
                    print("in range false")
                }
            default:
               activity.shouldNotify = false
                print("default false")
            }
            saveActivities()
        }
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addActivity" {
            let controller = segue.destination as! ActivityDetailsViewController
            controller.delegate = self
            controller.notificationTemp = String(weatherData.temperature)
            controller.notificationWeather = String(weatherData.condition)
            
            //get rid of date after testing
            controller.notificationDate = weatherData.date
        } else if segue.identifier == "editActivity" {
            let controller = segue.destination as! ActivityDetailsViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.activityToEdit = activities[indexPath.row]
                controller.selectedWeatherConditions = activities[indexPath.row].activityWeatherConditions
                controller.notificationTemp = String(weatherData.temperature)
                controller.notificationWeather = String(weatherData.condition)
                
                //get rid of date after testing
                controller.notificationDate = weatherData.date
            }
        }
    }
}

