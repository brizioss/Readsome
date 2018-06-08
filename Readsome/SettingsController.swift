//
//  SettingsController.swift
//  
//
//  Created by Sorgente Fabrizio on 03/06/18.
//

import UIKit

class SettingsController: UITableViewController {

    
    @IBOutlet weak var iCloudIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var iCloudSwitch: UISwitch!
    
    let preferences = UserDefaults.standard
        
    @IBAction func iCloudEnabled(_ sender: UISwitch) {
        
        
        self.iCloudIndicator.startAnimating()
        self.iCloudIndicator.isHidden = false
        sender.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//            if FileManager.default.ubiquityIdentityToken != nil {
        
            if sender.isOn {
                self.preferences.set(true, forKey: "iCloudEnabled")
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
                    
                }))
                alert.addAction(UIAlertAction(title: "No", style : .default, handler : {(alert: UIAlertAction!) in
                    self.iCloudIndicator.startAnimating()
                    ScannedTextManager.desyncWithiCloud()
                    self.iCloudIndicator.stopAnimating()
                    sender.isEnabled = true
                    
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
                
                print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
            }
//        }else{
//            let title = NSLocalizedString("Log-in to iCloud ", comment : "")
//            let message = NSLocalizedString("You can't enable the iCloud service because you are not logged in", comment : "")
//
//            // Set an "OK" action for the dialog
//            let alert = UIAlertController(title : title, message : message, preferredStyle : .alert)
//            alert.addAction(UIAlertAction(title: "OK", style : .default, handler : nil))
//
//            // Show the alert dialog
//            self.present(alert, animated : true, completion : nil)
//            self.preferences.set(false, forKey: "iCloudEnabled")
//            self.iCloudSwitch.setOn(false, animated: true)
//            print("iCloud enabled: "  + String(self.preferences.bool(forKey: "iCloudEnabled")))
//                self.iCloudIndicator.stopAnimating()
//                sender.isEnabled = true
//        }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if FileManager.default.ubiquityIdentityToken != nil {
        // Setting the switch status to represent the user's preference
            iCloudSwitch.setOn(preferences.bool(forKey: "iCloudEnabled"), animated: false)
//        }else{
//            iCloudSwitch.setOn(false, animated: true)
//            preferences.set(false, forKey: "iCloudEnabled")
//        }
    }
    


}
