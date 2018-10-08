//
//  ViewController.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
}

class ActivitiesViewController: UITableViewController {
    var activities = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: - TableView Delegate Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ActivityTableViewCell
        cell.activityNameLabel?.text = activities[indexPath.row].name
        cell.weatherIconImageView?.image = UIImage(named: activities[indexPath.row].weatherIcon)
        return cell
    }
}

