//
//  ActivityDetailsViewController.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit
import UserNotifications

protocol ActivityDetailsViewControllerDelegate: class {
    func activityDetailsViewControllerDidCancel(_ controller: ActivityDetailsViewController)
    func activityDetailsViewController(_ controller: ActivityDetailsViewController, didFinishAdding activity: Activity)
    func activityDetailsViewController(_ controller: ActivityDetailsViewController, didFinishEditing activity: Activity)
}

class ActivityDetailsViewController: UITableViewController, WeatherConditionsPickerViewControllerDelegate, UITextFieldDelegate {
    var activity = Activity()
    var activityToEdit: Activity?
    var notifyTime = Date()
    var datePickerVisible = false
    var observer: Any!
    var selectedWeatherConditions = [String]()
    weak var delegate: ActivityDetailsViewControllerDelegate?
    
//    var activityToEdit: Activity? {
//        didSet {
//            if let activity = activityToEdit {
//                descriptionText = activity.description
//                lowTemp = activity.lowTemp
//                highTemp = activity.highTemp
//            }
//        }
//    }
    
    //MARK: - IBOutlets
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var lowTempTextField: UITextField!
    @IBOutlet weak var highTempTextField: UITextField!
    @IBOutlet weak var shouldNotifySwitch: UISwitch!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //MARK: - IBActions
    @IBAction func notificationTimeChanged(_ datePicker: UIDatePicker) {
        notifyTime = datePicker.date
        updateNotificationTimeLabel()
    }
    
    @IBAction func shouldNotifyToggled(_ switchControl: UISwitch) {
        descriptionTextField.resignFirstResponder()
        
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {
                granted, error in
                //do nothing
            }
        }
    }
    
    @IBAction func doneBarButtonPressed() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        #warning("handle invalid temp. range inputs better")
        let title = "Warning:"
        let message = "\"Low temp.\" value must be less than \"High temp.\" value."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        if let lowTempInt = Int(lowTempTextField.text!), let highTempInt = Int(highTempTextField.text!) {
            if lowTempInt >= highTempInt {
                hudView.hide()
                present(alert, animated: true)
            }
        }
        
        if let activityToEdit = activityToEdit {
            hudView.text = "Updated"
            activityToEdit.activityDescription = descriptionTextField.text!
            activityToEdit.lowTemp = lowTempTextField.text!
            activityToEdit.highTemp = highTempTextField.text!
            activityToEdit.shouldNotify = shouldNotifySwitch.isOn
            activityToEdit.notifyTime = notifyTime
            activityToEdit.activityWeatherConditions = selectedWeatherConditions
            activityToEdit.scheduleNotification()
            delegate?.activityDetailsViewController(self, didFinishEditing: activityToEdit)
        } else {
            hudView.text = "Added"
            let activity = Activity()
            activity.activityDescription = descriptionTextField.text!
            activity.lowTemp = lowTempTextField.text!
            activity.highTemp = highTempTextField.text!
            activity.shouldNotify = shouldNotifySwitch.isOn
            activity.notifyTime = notifyTime
            activity.activityWeatherConditions = selectedWeatherConditions
            activity.scheduleNotification()
            delegate?.activityDetailsViewController(self, didFinishAdding: activity)
        }
        afterDelay(0.7) {
            hudView.hide()
        }
    }
    
    @IBAction func cancelBarButtonPressed() {
        delegate?.activityDetailsViewControllerDidCancel(self)
    }
    
    @IBAction func doneKeyboardButtonPressed(_ sender: UITextField) {
        resignFirstResponder()
    }
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "blueSkies"))
//        shouldNotifySwitch.isOn = activity.shouldNotify //do i need this line since have it in activityToEdit?
        
        if let activityToEdit = activityToEdit {
            title = "Edit Activity"
            doneBarButton.isEnabled = true
            descriptionTextField.text = activityToEdit.activityDescription
            lowTempTextField.text = activityToEdit.lowTemp
            highTempTextField.text = activityToEdit.highTemp
            shouldNotifySwitch.isOn = activityToEdit.shouldNotify
            notifyTime = activityToEdit.notifyTime
            print("conditions: \(activityToEdit.activityWeatherConditions)")
        }
        
        updateNotificationTimeLabel()
        listenForBackgroundNotification()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: - TableView Delegate Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 {
            return 163
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath
        } else if indexPath.section == 2 && indexPath.row == 2 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        descriptionTextField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 1 {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
    
    // need this since overriding data source for a static table view cell otherwise crash
    // data source doesn't know about the datePicker cell so trick it into thinking there are 3 rows when picker visible
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    //MARK: - WeatherConditionsPickerViewControllerDelegate Functions
    func updateWeatherConditions(conditions: [String]) {
        selectedWeatherConditions = conditions
    }
    
    //MARK: - Other Functions
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            if let weakSelf = self {
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: false, completion: nil)
                }
                weakSelf.descriptionTextField.resignFirstResponder()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextField.resignFirstResponder()
        lowTempTextField.resignFirstResponder()
        highTempTextField.resignFirstResponder()
    }
    
    func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
    }
    
    func updateNotificationTimeLabel() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        notificationTimeLabel.text = formatter.string(from: notifyTime)
    }
    
    func showDatePicker() {
        datePicker.datePickerMode = .time
        datePickerVisible = true
        let indexPathDateRow = IndexPath(row: 1, section: 1)
        let indexPathDatePicker = IndexPath(row: 2, section: 1)
        
        if let dateCell = tableView.cellForRow(at: indexPathDateRow) {
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        // since doing two things to table view at same time, need the update calls so animate at same time
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.endUpdates()
        datePicker.setDate(notifyTime, animated: false)
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = IndexPath(row: 1, section: 1)
            let indexPathDatePicker = IndexPath(row: 2, section: 1)
            
            if let cell = tableView.cellForRow(at: indexPathDateRow) {
                cell.detailTextLabel!.textColor = UIColor.black
            }
            
            // since doing two things to table view at same time, need the update calls so animate at same time
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPathDateRow], with: .none)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            tableView.endUpdates()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = "Back"
        navigationItem.backBarButtonItem = backButtonItem
        
        if segue.identifier == "weatherConditionsSegue" {
            let controller = segue.destination as! WeatherConditionsPickerViewController
            controller.delegate = self
            
            if let activityToEdit = activityToEdit {
                controller.selectedWeatherConditions = activityToEdit.activityWeatherConditions
            }
        }
    }
}
