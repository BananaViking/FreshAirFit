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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as! WeatherConditionsTableViewCell
//        cell.activityDescriptionLabel?.text = activities[indexPath.row].activityDescription
        cell.weatherIcon.image = UIImage(named: "sunny")
        cell.weatherCondition.text = "Sunny"
        return cell
    }
    
    // need to add deselect row after click, add checkmark, feed data back to other VC's
    // make an array for all checked weather conditions and AVC label should display "Weather: " then list whole array for checked conditions
}
