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
    let weatherURL = "http://api.openweathermap.org/data/2.5/weather"
    let appID = "63b1578537bf98519c346221f7f4efda"
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
    
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
    
    func checkWeather() {
        
    }
    
    //MARK: - JSON Parsing
    func updateWeatherData(json: JSON) {
        let tempResult = json["main"]["temp"].doubleValue
        weatherData.temperature = Int(9/5 * (tempResult - 273) + 32)
        weatherData.city = json["name"].stringValue
        weatherData.conditionCode = json["weather"][0]["id"].intValue
        
        #warning("update these condition ranges from openweathermap.org/weather-conditions and also to read sensibly when inserted into notification sentence")
        switch weatherData.conditionCode {
        case 0...300, 772...799, 900...903, 905...1000:
            weatherData.condition = "thunderstorm"
        case 301...500:
            weatherData.condition = "light rain"
        case 501...600:
            weatherData.condition = "showers"
        case 601...700, 903:
            weatherData.condition = "snowing"
        case 701...771:
            weatherData.condition = "fog"
        case 800:
            weatherData.condition = "sunny"
        case 801...804:
            weatherData.condition = "cloudy"
        case 904 :
            weatherData.condition = "sunny"
        default :
            weatherData.condition = "unknown weather condition"
        }
        print(json)
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addActivity" {
            let controller = segue.destination as! ActivityDetailsViewController
            controller.delegate = self
            controller.notificationTemp = String(weatherData.temperature)
            controller.notificationWeather = String(weatherData.condition)
        } else if segue.identifier == "editActivity" {
            let controller = segue.destination as! ActivityDetailsViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.activityToEdit = activities[indexPath.row]
//                controller.activityToEdit?.activityWeatherConditions = activities[indexPath.row].activityWeatherConditions
                controller.selectedWeatherConditions = activities[indexPath.row].activityWeatherConditions
                controller.notificationTemp = String(weatherData.temperature)
                controller.notificationWeather = String(weatherData.condition)
            }
        }
    }
}

