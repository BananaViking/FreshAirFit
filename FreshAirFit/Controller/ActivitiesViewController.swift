//
//  ViewController.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
}

class ActivitiesViewController: UITableViewController, ActivityDetailsViewControllerDelegate {
    var activities = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "blueSkies"))
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
        
        var conditionsLabelText = "Temp: "
        if !activities[indexPath.row].lowTemp.isEmpty && activities[indexPath.row].highTemp.isEmpty {
            conditionsLabelText += ">\(activities[indexPath.row].lowTemp)°"
        } else if activities[indexPath.row].lowTemp.isEmpty && !activities[indexPath.row].highTemp.isEmpty {
            conditionsLabelText += "<\(activities[indexPath.row].highTemp)°"
        } else if !activities[indexPath.row].lowTemp.isEmpty && !activities[indexPath.row].highTemp.isEmpty {
            conditionsLabelText += "\(activities[indexPath.row].lowTemp)° - \(activities[indexPath.row].highTemp)°"
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
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addActivity" {
            let controller = segue.destination as! ActivityDetailsViewController
            controller.delegate = self
        } else if segue.identifier == "editActivity" {
            let controller = segue.destination as! ActivityDetailsViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.activityToEdit = activities[indexPath.row]
            }
        }
    }
}

