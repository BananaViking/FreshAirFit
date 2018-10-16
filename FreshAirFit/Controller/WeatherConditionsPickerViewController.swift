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

protocol WeatherConditionsPickerViewControllerDelegate: class {
    func weatherPickerViewController(_ controller: WeatherConditionsPickerViewController, didFinishUpdating conditions: [String])
}

class WeatherConditionsPickerViewController: UITableViewController {
    weak var delegate: WeatherConditionsPickerViewControllerDelegate?
    let weatherConditionBank = WeatherConditionBank()
    var selectedWeatherConditions = [String]()
    
    override func viewDidLoad() {
        tableView.backgroundView = UIImageView(image: UIImage(named: "blueSkies"))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherConditionBank.weatherConditions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as! WeatherConditionsTableViewCell
        cell.weatherIcon.image = UIImage(named: weatherConditionBank.weatherConditions[indexPath.row].weatherIcon)
        cell.weatherCondition.text = weatherConditionBank.weatherConditions[indexPath.row].weatherConditionDescription
        if weatherConditionBank.weatherConditions[indexPath.row].isChecked == false {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    //******************************************************
    //checkmarks aren't getting saved
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                weatherConditionBank.weatherConditions[indexPath.row].isChecked = true
                selectedWeatherConditions.append(weatherConditionBank.weatherConditions[indexPath.row].weatherConditionDescription)
                delegate?.weatherPickerViewController(self, didFinishUpdating: selectedWeatherConditions)
                print(selectedWeatherConditions)
            } else {
                cell.accessoryType = .none
                weatherConditionBank.weatherConditions[indexPath.row].isChecked = false
                selectedWeatherConditions.removeAll { $0 == weatherConditionBank.weatherConditions[indexPath.row].weatherConditionDescription }
                delegate?.weatherPickerViewController(self, didFinishUpdating: selectedWeatherConditions)
                print(selectedWeatherConditions)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // need to feed data back to other VC's
    // make an array for all checked weather conditions and AVC label should display "Weather: " then list whole array for checked conditions
}
