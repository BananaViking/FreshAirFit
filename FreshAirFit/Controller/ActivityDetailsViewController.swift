//
//  ActivityDetailsViewController.swift
//  FreshAirFit
//
//  Created by Banana Viking on 10/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class ActivityDetailsViewController: UITableViewController, UITextViewDelegate {
    var activity = Activity()
    var weatherConditions = [String]()
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
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var lowTempValue: UITextField!
    @IBOutlet weak var highTempValue: UITextField!
    
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Added"
        afterDelay(0.6) {
            hudView.hide()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.delegate = self
        descriptionTextView.text = activity.description
        lowTempValue.text = activity.lowTemp
        highTempValue.text = activity.highTemp
        descriptionTextView.textColor = UIColor.lightGray
        
//        if let activity = activityToEdit {
//            title = "Edit Activity"
//            if activity.description.isEmpty {
//                descriptionTextView.textColor = UIColor.lightGray
//                descriptionTextView.text = "Add a description here..."
//            } else {
//                descriptionTextView.textColor = UIColor.black
//                descriptionTextView.text = activity.description
//            }
//        }
        
        listenForBackgroundNotification()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: - TableView Delegate Functions
    
    //MARK: - TextView Delegate Functions
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Dispatch block puts cursor placement code on next run cycle so doesn't get called at same time as the rest of function
        DispatchQueue.main.async {
            let newPosition = self.descriptionTextView.endOfDocument
            self.descriptionTextView.selectedTextRange = self.descriptionTextView.textRange(from: newPosition, to: newPosition)
        }
        
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Add a description here..."
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: - Other Functions
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            if let weakSelf = self {
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: false, completion: nil)
                }
                weakSelf.descriptionTextView.resignFirstResponder()
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
        descriptionTextView.resignFirstResponder()
    }
    
    func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
    }
}
