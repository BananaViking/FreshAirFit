//
//  ActivityDetailsViewController.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit
import UserNotifications

class ActivityDetailsViewController: UITableViewController, UITextFieldDelegate {
    var activity = Activity()
    var activityToEdit: Activity?
    var notifyTime = Date()
    var datePickerVisible = false
    var observer: Any!
    
//    var activityToEdit: Activity? {
//        didSet {
//            if let activity = activityToEdit {
//                descriptionText = activity.description
//                lowTemp = activity.lowTemp
//                highTemp = activity.highTemp
//            }
//        }
//    }
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var lowTempValue: UITextField!
    @IBOutlet weak var highTempValue: UITextField!
    @IBOutlet weak var shouldNotifySwitch: UISwitch!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    
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
        hudView.text = "Added"
        afterDelay(0.6) {
            hudView.hide()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelBarButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneKeyboardButtonPressed(_ sender: UITextField) {
        resignFirstResponder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lowTempValue.text = activity.lowTemp
        highTempValue.text = activity.highTemp
        shouldNotifySwitch.isOn = activity.shouldNotify
        
        
        if let activityToEdit = activityToEdit {
            title = "Edit Activity"
            descriptionTextField.text = activityToEdit.activityDescription
        }
        
        listenForBackgroundNotification()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        descriptionTextField.becomeFirstResponder()
    }
    
    //MARK: - TableView Delegate Functions
    
    
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
    }
    
    func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
    }
    
    func updateNotificationTimeLabel() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        notificationTimeLabel.text = formatter.string(from: notifyTime)
    }
    
    func showDatePicker() {  // HQ DailyDetailVC
        
    }
    
    func hideDatePicker() {  // HQ DailyDetailVC
        
    }
    
    //MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "addActivity" {
//            
//        } else if segue.identifier == "editActivity" {
//            let controller = segue.destination as! ActivityDetailsViewController
//            controller.delegate = self
//            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
//                controller.activityToEdit = activities[indexPath.row]
//            }
//        }
//    }
}
