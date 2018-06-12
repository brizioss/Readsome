//
//  SettingsController.swift
//  
//
//  Created by Sorgente Fabrizio on 03/06/18.
//

import UIKit
import CloudKit

class SettingsController: UITableViewController {
    
    @IBOutlet weak var iCloudIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var iCloudSwitch: UISwitch!
        
    let preferences = UserDefaults.standard
    
    @IBAction func iCloudEnabled(_ sender: UISwitch) {
    
        if ScannedTextManager.iCloudChecker() {
                                        self.iCloudIndicator.startAnimating()
                                        self.iCloudIndicator.isHidden = false
                                        sender.isEnabled = false

                                        if sender.isOn {
                                            self.preferences.set(true, forKey: "iCloudEnabled")
                                            
//                                            if !NSUbiquitousKeyValueStore.default.bool(forKey: "subscribed"){
//                                                self.setCloudKitSubscription()
//                                            }
                                            
                                            if !UserDefaults.standard.bool(forKey: "subscribed"){
                                                self.setCloudKitSubscription()
                                            }
                                            
                                            //////////////////////////////////////// TO DO
//                                            if ScannedTextManager.loadAll().count > 0 {
//                                                
//                                                let title = NSLocalizedString("Synchronizing", comment : "")
//                                                let message = NSLocalizedString("Would you like to save your library in iCloud?", comment : "")
//                                                
//                                                // Set an "OK" action for the dialog
//                                                let alert = UIAlertController(title : title, message : message, preferredStyle : .alert)
//                                                alert.addAction(UIAlertAction(title: "Yes", style : .destructive, handler : {(alert: UIAlertAction!) in
//                                                    
//                                                    
//                                                    self.iCloudIndicator.stopAnimating()
//                                                    sender.isEnabled = true
//                                                    print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
//                                                }))
//                                                alert.addAction(UIAlertAction(title: "No", style : .default, handler : {(alert: UIAlertAction!) in
//                                                    self.iCloudIndicator.startAnimating()
//                                                    ScannedTextManager.desyncWithiCloud()
//                                                    self.iCloudIndicator.stopAnimating()
//                                                    sender.isEnabled = true
//                                                    print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
//                                                }))
//                                                
//                                                alert.addAction(UIAlertAction(title: "Cancel", style : .cancel, handler : {(alert: UIAlertAction!) in
//                                                    self.iCloudIndicator.startAnimating()
//                                                    self.preferences.set(true, forKey: "iCloudEnabled")
//                                                    self.iCloudSwitch.setOn(true, animated: true)
//                                                    self.iCloudIndicator.stopAnimating()
//                                                    sender.isEnabled = true
//                                                    print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
//                                                }))
//                                                
//                                                // Show the alert dialog
//                                                self.present(alert, animated : true, completion : nil)
//                                                
//                                            }
                                            ///////////////////////////////////////////////// TO DO

                                            
                                            
                                            
                                            
                                            ScannedTextManager.syncWithiCloud()
                                            self.iCloudIndicator.stopAnimating()
                                            sender.isEnabled = true
                                            print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
                                        }else{
                                            self.preferences.set(false ,forKey: "iCloudEnabled")
                                            let title = NSLocalizedString("Deleting", comment : "")
                                            let message = NSLocalizedString("Would you delete all the elements from the Cloud?", comment : "")

                                            // Set an "OK" action for the dialog
                                            let alert = UIAlertController(title : title, message : message, preferredStyle : .alert)
                                            alert.addAction(UIAlertAction(title: "Yes", style : .destructive, handler : {(alert: UIAlertAction!) in
                                                self.iCloudIndicator.startAnimating()
                                                ScannedTextManager.deleteAllFromiCloud()
                                                ScannedTextManager.desyncWithiCloud()
                                                self.iCloudIndicator.stopAnimating()
                                                sender.isEnabled = true
                                                print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
                                            }))
                                            alert.addAction(UIAlertAction(title: "No", style : .default, handler : {(alert: UIAlertAction!) in
                                                self.iCloudIndicator.startAnimating()
                                                ScannedTextManager.desyncWithiCloud()
                                                self.iCloudIndicator.stopAnimating()
                                                sender.isEnabled = true
                                                print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
                                            }))

                                            alert.addAction(UIAlertAction(title: "Cancel", style : .cancel, handler : {(alert: UIAlertAction!) in
                                                self.iCloudIndicator.startAnimating()
                                                self.preferences.set(true, forKey: "iCloudEnabled")
                                                self.iCloudSwitch.setOn(true, animated: true)
                                                self.iCloudIndicator.stopAnimating()
                                                sender.isEnabled = true
                                                print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
                                            }))

                                            // Show the alert dialog
                                            self.present(alert, animated : true, completion : nil)
                                        }
        }else{
            let title2 = NSLocalizedString("Missing Connection or Permission", comment : "")
            let message2 = NSLocalizedString("Check your iCloud settings and your internet connection", comment : "")

            // Set an "OK" action for the dialog
            let alert2 = UIAlertController(title : title2, message : message2, preferredStyle : .alert)
            alert2.addAction(UIAlertAction(title: "Ok", style : .cancel, handler : {(alert: UIAlertAction!) in
                self.iCloudSwitch.setOn(false, animated: false)
                print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
            }))

            // Show the alert dialog
            self.present(alert2, animated : true, completion : nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ScannedTextManager.iCloudChecker(){
            DispatchQueue.main.async {
                self.iCloudSwitch.setOn(self.preferences.bool(forKey: "iCloudEnabled"), animated: true)
            }
        }else{
            self.preferences.set(false, forKey: "iCloudEnabled")
            DispatchQueue.main.async {
                self.iCloudSwitch.setOn(false, animated: false)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool){
        
        if ScannedTextManager.iCloudChecker(){
            DispatchQueue.main.async {
                self.iCloudSwitch.setOn(self.preferences.bool(forKey: "iCloudEnabled"), animated: true)
            }
        }else{
            self.preferences.set(false, forKey: "iCloudEnabled")
            DispatchQueue.main.async {
                self.iCloudSwitch.setOn(false, animated: false)
            }
        }
        print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
    }
    
    func setCloudKitSubscription(){
    
            let privateData = CKContainer.default().privateCloudDatabase
            
            let predicate = NSPredicate(format: "TRUEPREDICATE")
            
            let subscription = CKSubscription(recordType: "ScannedText", predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
            
            let notificationInfo = CKNotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            //            notificationInfo.alertBody = "Check the app"
            
            subscription.notificationInfo = notificationInfo
            
            privateData.save(subscription,completionHandler: ({returnRecord, error in
                if let err = error {
                    print("Subscription On creation failed %@", err.localizedDescription)
                } else {
                    print("Success - message: Subscription On Creation set up successfully")
                    UserDefaults.standard.set(true, forKey: "subscribedOnCreation")
                }
            }))
    }
    
    
    
    //    func setCloudKitSubscription(){
    //        //        && !NSUbiquitousKeyValueStore.default.bool(forKey: "subscribed")
    //        if ScannedTextManager.iCloudChecker() {
    //
    //            let privateData = CKContainer.default().privateCloudDatabase
    //
    //            let predicate = NSPredicate(format: "TRUEPREDICATE")
    //
    //            let subscription = CKSubscription(recordType: "ScannedText", predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
    //
    //            subscription.notificationInfo = CKNotificationInfo()
    //
    //
    //            privateData.fetchAllSubscriptions(completionHandler: {subscriptions, error in
    //
    //                if error == nil{
    //                    for subscriptionObject in subscriptions!{
    //                        privateData.delete(withSubscriptionID: subscriptionObject.subscriptionID, completionHandler: {subscriptionId, error in
    //                            if error == nil{
    //                                print("Subscription with id \(subscriptionObject.subscriptionID) was removed : \(subscriptionObject.description)")
    //                            }else{
    //                                print(error as Any)
    //                            }
    //
    //                        })
    //                    }
    //                }else{
    //                    print(error as Any)
    //                }
    //            })
    //
    //            privateData.save(subscription,completionHandler: ({returnRecord, error in
    //                if let err = error {
    //                    print("Subscription On creation failed %@", err.localizedDescription)
    //                    NSUbiquitousKeyValueStore.default.set(false, forKey: "subscribed")
    //                } else {
    //                    print("Success - message: Subscription up successfully")
    //                    NSUbiquitousKeyValueStore.default.set(true, forKey: "subscribed")
    //                }
    //            }))
    //        }
    //    }

}
