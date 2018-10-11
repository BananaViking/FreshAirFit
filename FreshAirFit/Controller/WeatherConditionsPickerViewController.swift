//
//  WeatherConditionsPicker.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/10/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class WeatherConditionsTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherCondition: UILabel!
}

class WeatherConditionsPickerViewController: UITableViewController {
    let weatherConditionBank = WeatherConditionBank()
    
    override func viewDidLoad() {
        tableView.backgroundView = UIImageView(image: UIImage(named: "blueSkies"))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherConditionBank.weatherConditions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as! WeatherConditionsTableViewCell
//        cell.activityDescriptionLabel?.text = activities[indexPath.row].activityDescription
        cell.weatherIcon.image = UIImage(named: weatherConditionBank.weatherConditions[indexPath.row].weatherIcon)
        cell.weatherCondition.text = weatherConditionBank.weatherConditions[indexPath.row].weatherConditionDescription
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // need to add deselect row after click, add checkmark, feed data back to other VC's
    // make an array for all checked weather conditions and AVC label should display "Weather: " then list whole array for checked conditions
}
