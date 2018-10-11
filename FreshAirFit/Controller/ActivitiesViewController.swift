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
        loadActivities()  //do I still need this? check book
    }

    //MARK: - TableView Delegate Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ActivityTableViewCell
        cell.activityDescriptionLabel?.text = activities[indexPath.row].activityDescription
        cell.conditionsLabel?.text = "Temp: \(activities[indexPath.row].lowTemp)° - \(activities[indexPath.row].highTemp)°"
        cell.weatherLabel?.text = "Weather: Sunny, Partly cloudy" // HOOK THIS UP TO USER ENTRY CONDITIONS CHECKMARK ARRAY
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
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
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

