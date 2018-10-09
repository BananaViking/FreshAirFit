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

class ActivityDetailsViewController: UITableViewController, UITextFieldDelegate {
    var activity = Activity()
    var activityToEdit: Activity?
    var notifyTime = Date()
    var datePickerVisible = false
    var observer: Any!
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
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var lowTempTextField: UITextField!
    @IBOutlet weak var highTempTextField: UITextField!
    @IBOutlet weak var shouldNotifySwitch: UISwitch!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
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
        if let activityToEdit = activityToEdit {
            hudView.text = "Updated"
            activityToEdit.activityDescription = descriptionTextField.text!
            activityToEdit.lowTemp = lowTempTextField.text!
            activityToEdit.highTemp = highTempTextField.text!
            delegate?.activityDetailsViewController(self, didFinishEditing: activityToEdit)
        } else {
            hudView.text = "Added"
            let activity = Activity()
            activity.activityDescription = descriptionTextField.text!
            activity.lowTemp = lowTempTextField.text!
            activity.highTemp = highTempTextField.text!
            delegate?.activityDetailsViewController(self, didFinishAdding: activity)
        }
        afterDelay(0.6) {
            hudView.hide()
        }
    }
    
    @IBAction func cancelBarButtonPressed() {
        delegate?.activityDetailsViewControllerDidCancel(self)
    }
    
    @IBAction func doneKeyboardButtonPressed(_ sender: UITextField) {
        resignFirstResponder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldNotifySwitch.isOn = activity.shouldNotify
        
        if let activityToEdit = activityToEdit {
            title = "Edit Activity"
            doneBarButton.isEnabled = true
            descriptionTextField.text = activityToEdit.activityDescription
            lowTempTextField.text = activityToEdit.lowTemp
            highTempTextField.text = activityToEdit.highTemp
        }
        
        listenForBackgroundNotification()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
}
