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
}

class ActivitiesViewController: UITableViewController, ActivityDetailsViewControllerDelegate {
    var activities = [Activity]()
    var sampleActivity = Activity()
    
    @IBAction func addActivity() {
        let newRowIndex = activities.count
        let otherActivity = Activity()
        otherActivity.activityDescription = "Swimming"
        activities.append(otherActivity)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activities.append(sampleActivity)
        sampleActivity.activityDescription = "Hiking"
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: - TableView Delegate Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ActivityTableViewCell
        cell.activityDescriptionLabel?.text = activities[indexPath.row].activityDescription
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        activities.remove(at: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    //MARK: - ActivityDetailsViewControllerDelegate Functions
    func activityDetailsViewControllerDidCancel(_ controller: ActivityDetailsViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func activityDetailsViewController(_ controller: ActivityDetailsViewController, didFinishAdding activity: Activity) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Other Functions
    
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

