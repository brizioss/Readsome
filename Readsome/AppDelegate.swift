//
//  AppDelegate.swift
//  Readsome
//
//  Created by Nello Carotenuto on 05/03/18.
//  Copyright © 2018 Readsome. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window : UIWindow?
    let preferences = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        application.registerForRemoteNotifications()

        

        if preferences.string(forKey: "font-family") == nil {
            self.preferences.set("Times New Roman", forKey: "font-family")
        }
        
        if preferences.bool(forKey: "iCloudEnabled").description == "" {
            self.preferences.set("Times New Roman", forKey: "font-family")
        }
        
        // Initialize text size
        let textSize = preferences.float(forKey: "text-size")
        
        if textSize == 0 {
            preferences.set(20, forKey: "text-size")
        }
        
        
        // Initialize the dictionary of letters
        let letters = preferences.dictionary(forKey: "letters")
        
        if letters == nil {
            preferences.set([String : NSData](), forKey : "letters")
        }
        
        
        // Initialize text-to-speech
        let volume = preferences.float(forKey : "volume")
        
        if volume == 0 {
            preferences.set(0.7, forKey : "volume")
        }
        
        let pitch = preferences.float(forKey : "pitch")
        
        if pitch == 0 {
            preferences.set(1.15, forKey : "pitch")
        }
        
        let rate = preferences.float(forKey : "rate")
        
        if rate == 0 {
            preferences.set(0.5, forKey : "rate")
        }
        
        // Make audio audible even in silent mode
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print("Error: unable to make audio audible in silent mode")
        }
        
        
      
        
        
        return true
    }
    
//
//    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//        print("Recived: \(userInfo)")
//
//
//        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String:NSObject])
//        print("E' ENTRATO QUI 3")
//
//        if cloudKitNotification.notificationType == CKNotificationType.query {
//            print("E' ENTRATO QUI 1")
//
//            DispatchQueue.main.async {
//                print("E' ENTRATO QUI 2")
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "performReload"), object: nil)
//            }
//        }
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        if ScannedTextManager.iCloudChecker() && UserDefaults.standard.bool(forKey: "iCloudEnabled"){
            DispatchQueue.main.async {
                ScannedTextManager.syncWithiCloud()
                NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Readsome")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

//    func registerForPushNotifications() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//            (granted, error) in
//            print("Permission granted: \(granted)")
//
//            guard granted else { return }
//            self.getNotificationSettings()
//        }
//    }
    
//    func getNotificationSettings() {
//        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//            print("Notification settings: \(settings)")
//            guard settings.authorizationStatus == .authorized else { return }
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
//    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
        let tokenParts = deviceToken.map { data -> String in
    return String(format: "%02.2hhx", data)
    }
    
    let token = tokenParts.joined()
    print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\nUSERINFO : \(userInfo)\n")
         DispatchQueue.main.async {
            if UserDefaults.standard.bool(forKey: "iCloudEnabled"){
                
                let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
                
                if notification.queryNotificationReason == .recordCreated {
                    
                    
                    let ck = userInfo["ck"] as? NSDictionary
                    let qry = ck!["qry"] as? NSDictionary
                    let rid = qry!["rid"] as? String
                    
                    print("RECORD ADDED - recordname: " + rid!)
                    ScannedTextManager.addInCoreDataFromNotification(by: rid!)
//                    ScannedTextManager.syncWithiCloud()
                }
                
                if notification.queryNotificationReason == .recordDeleted {
                    
                    let ck = userInfo["ck"] as? NSDictionary
                    let qry = ck!["qry"] as? NSDictionary
                    let rid = qry!["rid"] as? String
                    
                    print("RECORD DELETED - recordname: " + rid!)
                    ScannedTextManager.deleteInCoreDataFromNotification(by: rid!)
                }
                
       
            let aps = userInfo["aps"] as! [String: AnyObject]
                if aps["content-available"] as? Int == 1 {
                    self.saveContext()
                    }
            }
        }
    }

}
