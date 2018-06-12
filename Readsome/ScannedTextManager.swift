//
//  ScannedTextManager.swift
//  Readsome
//
//  Created by Nello Carotenuto on 09/03/18.
//  Copyright © 2018 Readsome. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CloudKit

class ScannedTextManager {
    
    
    static let name = "ScannedText"
    
    static func getContext() -> NSManagedObjectContext {let appDelegate: AppDelegate
        if Thread.current.isMainThread {
            appDelegate = UIApplication.shared.delegate as! AppDelegate
        } else {
            appDelegate = DispatchQueue.main.sync {
                return UIApplication.shared.delegate as! AppDelegate
            }
        }
        return appDelegate.persistentContainer.viewContext
    }
    
   
    
    
    static func add(title : String, text : String, image : UIImage) {
        let context = getContext()
        
        let scannedText = NSEntityDescription.insertNewObject(forEntityName : name, into : context) as! ScannedText
        
        scannedText.title = title
        scannedText.text = text
        scannedText.image =  UIImageJPEGRepresentation(image, CGFloat(0.25)) as NSData?
        scannedText.position = loadAll().count - 1
        scannedText.isIniCloud = false
        
        /// Add the item to iCloud
        if UserDefaults.standard.bool(forKey: "iCloudEnabled") {
            print("Saving on iCloud...")
            addToiCloud(title: title,text: text,image: image, scannedText: scannedText)
        }
        save()
        NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil)
    }
    
    static func addToiCloud(title : String, text : String, image : UIImage, scannedText : ScannedText){
            if self.iCloudChecker(){
                
                let CloudScannedText = CKRecord(recordType: "ScannedText")
                
                CloudScannedText.setValue(title, forKey: "title")
                CloudScannedText.setValue(text, forKey: "text")
                
                //get the image path
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
                
                let localPath = documentDirectory + "/profilePicture"
                let data = UIImageJPEGRepresentation(image, CGFloat(0.25))
                let imageURL = NSURL(fileURLWithPath: localPath)
                
                do {
                    try data?.write(to: imageURL as URL)
                } catch {
                    print(error.localizedDescription)
                }
                
                let asset = CKAsset(fileURL: imageURL as URL)
                
                CloudScannedText.setValue(asset, forKey: "image")
                
                let privateData = CKContainer.default().privateCloudDatabase
                privateData.save(CloudScannedText) { (record, error) in
                    ///    print(error)
                    scannedText.iCloudRecordName = CloudScannedText.recordID.recordName
                    if error != nil{
                        print(String(describing: error))
                    }else{
                        print("Record aggiunto su iCloud con recordName = " + scannedText.iCloudRecordName!)
                        scannedText.isIniCloud = true
                    }
                }
            }
    }
    
    
    static func addInCoreDataFromNotification(by recordName : String){
        
            if self.iCloudChecker(){
                let privateDatabase = CKContainer.default().privateCloudDatabase
                
                privateDatabase.fetch(withRecordID: CKRecordID(recordName: recordName), completionHandler: {record, error in
                    if(record?.recordID.recordName == nil){
                        print("element to add in core data not found in iCloud")
                    }else{
                            let context = getContext()
                            let scannedText = NSEntityDescription.insertNewObject(forEntityName : name, into : context) as! ScannedText
                            if let asset = record?.value(forKey: "image") as? CKAsset,
                            let data = try? Data(contentsOf: asset.fileURL) {
                            scannedText.title = record?.value(forKey: "title") as! String
                            scannedText.text = record?.value(forKey: "text") as! String
                            scannedText.image =  UIImageJPEGRepresentation(UIImage(data: data)!, CGFloat(0.25)) as NSData?
                            scannedText.position = loadAll().count-1
                            scannedText.isIniCloud = true
                            scannedText.iCloudRecordName = record?.recordID.recordName
                            save()
                            print("Saved :::::::  " + scannedText.title! + " " + String(scannedText.position))
                            NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil)
                    }
                    }
                })
                
        }
    }

    
    static func loadAll() -> [ScannedText] {
        let context = getContext()
        
        var scannedTexts = [ScannedText]()
        let fetchRequest = NSFetchRequest<ScannedText>(entityName : name)
        
        do {
            scannedTexts = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.code)")
        }
        return scannedTexts
    }
    
    static func load(by index : Int) -> ScannedText {
        let context = getContext()
        
        var scannedTexts = [ScannedText]()
        
        let fetchRequest = NSFetchRequest<ScannedText>(entityName : name)
        fetchRequest.predicate = NSPredicate(format : "position = \(index)")
        
        do {
            scannedTexts = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.code)")
        }
        return scannedTexts[0]
    }
    
    static func load(by index : String) -> ScannedText {
        let context = getContext()
        
        var scannedTexts = [ScannedText]()
        
        let fetchRequest = NSFetchRequest<ScannedText>(entityName : name)
        fetchRequest.predicate = NSPredicate(format : "iCloudRecordName = %@",index)
        
        do {
            scannedTexts = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.code)")
        }
        
        return scannedTexts[0]
    }
    
    
    static func doesExists(index : String) -> Bool {
            let context = getContext()
        
            var fetchRequest = NSFetchRequest<ScannedText>(entityName: name)
            fetchRequest.predicate = NSPredicate(format: "iCloudRecordName = %@",index)
            
            var results = [ScannedText]()
            
            do {
                results = try context.fetch(fetchRequest)
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            
            return results.count > 0
        }
    
    static func doesExistsIniCloud(recordName : String) -> Bool {
        var temp = false

        let group = DispatchGroup()
        group.enter()
        
        // avoid deadlocks by not using .main queue here
        DispatchQueue.global(qos: .default).async{

                if self.iCloudChecker(){
                    let privateDatabase = CKContainer.default().privateCloudDatabase
                    
                    privateDatabase.fetch(withRecordID: CKRecordID(recordName: recordName), completionHandler: {record, error in
                        if(record?.recordID.recordName == nil){
                            temp = false
                        }else{
                            temp = true
                        }
                        group.leave()
                    })
                }else{
                    print("Can't access to iCloud")
            }
        }
        
        // wait ...
        group.wait()
        
        // ... and return as soon as "temp" has a value
        return temp
    }
    
    static func delete(by index : Int) {
        let context = getContext()
        
        let scannedText = load(by : index)
        let isInCloud = scannedText.isIniCloud
        let recordName = scannedText.iCloudRecordName
        
        context.delete(scannedText)
        
        let fetchRequest = NSFetchRequest<ScannedText>(entityName : name)
        fetchRequest.predicate = NSPredicate(format : "position > \(index)")
        
        do {
            let items = try context.fetch(fetchRequest)
            
            for item in items {
                item.position -= 1
            }
            
            save()
        } catch let error as NSError {
            print("Error: \(error.code)")
        }
        
        
        /// Delete the item from iCloud
        if UserDefaults.standard.bool(forKey: "iCloudEnabled") && isInCloud == true {
            deleteFromiCloud(by: recordName!)
        }
    }
    
    
    static func deleteInCoreDataFromNotification(by index : String) {
        
        if doesExists(index: index){
         
            let context = getContext()
            let scannedText = load(by : index)
            context.delete(scannedText)
            
            let fetchRequest = NSFetchRequest<ScannedText>(entityName : name)
            fetchRequest.predicate = NSPredicate(format : "position > \(scannedText.position)")
            
            do {
                let items = try context.fetch(fetchRequest)
                for item in items {
                    item.position -= 1
                }
                
                save()
                
            } catch let error as NSError {
                print("Error: \(error.code)")
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil)
}
    
    
    static func deleteFromiCloud(by recordName : String){
            if self.iCloudChecker(){
                let privateDatabase = CKContainer.default().privateCloudDatabase
                privateDatabase.delete(withRecordID: CKRecordID(recordName: recordName), completionHandler: {recordID, error in
                    if error != nil{
                        print(error as Any)
                    }
                })
            }
    }
    
    static func move(from : Int, to : Int) {
        let itemToMove = load(by : from)
        
        if from < to {
            for index in from...to {
                let item = load(by : index)
                
                item.position -= 1
            }
        } else if from > to {
            for index in to ..< from {
                let item = load(by : index)
                
                item.position += 1
            }
        }
        
        itemToMove.position = to
        
        save()
    }
    
    static func save() {
        let context = getContext()
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error :\(error.code)")
        }
    }
    
    // This function sync the whole library with iCloud
    static func syncWithiCloud() -> Void{
        print("SYNCHING.....................")
        let context = getContext()
        
        var scannedTexts = [ScannedText]()
        let fetchRequest = NSFetchRequest<ScannedText>(entityName : name)
        
        do {
            scannedTexts = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.code)")
        }
        
        for scannedText in scannedTexts {
            
            if scannedText.iCloudRecordName == nil{
//                in this case the item has not been added to iCloud
                addToiCloud(title: scannedText.title!, text: scannedText.text!, image: UIImage(data:scannedText.image! as Data)!, scannedText: scannedText)
                print("Record con RECORDNAME NIL aggiunto su iCloud : nil")
            }else if !doesExistsIniCloud(recordName: scannedText.iCloudRecordName!){
//                in this case the item is marked to delete from CoreData
                deleteInCoreDataFromNotification(by: scannedText.iCloudRecordName!)
                }else{
//                in this case the item is in iCloud and in CoreData
                print("Record con RECORDNAME GIA' AGGIUNTO IN PRECEDENZA non aggiunto su iCloud : " + String(scannedText.iCloudRecordName!))
                scannedText.isIniCloud = true
                }
        }
        
        
            if self.iCloudChecker() && UserDefaults.standard.bool(forKey: "iCloudEnabled"){
                let privateDatabase = CKContainer.default().privateCloudDatabase
                
                let query = CKQuery(recordType: "ScannedText", predicate: NSPredicate(format: "TRUEPREDICATE"))

                privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                    if error == nil {
                        for record in records! {
                            print("Recordname su icloud : " + record.recordID.recordName)
                            if !doesExists(index: record.recordID.recordName){
                                print("Recordname da aggiungere su coreData : " + record.recordID.recordName)
                                if let asset = record.value(forKey: "image") as? CKAsset,
                                let data = try? Data(contentsOf: asset.fileURL) {
                                    let scannedText = NSEntityDescription.insertNewObject(forEntityName : name, into : context) as! ScannedText
                                    scannedText.title = record.value(forKey: "title") as! String
                                    scannedText.text = record.value(forKey: "text") as! String
                                    scannedText.image =  UIImageJPEGRepresentation(UIImage(data: data)!, CGFloat(0.25)) as NSData?
                                    scannedText.position = loadAll().count - 1
                                    scannedText.isIniCloud = true
                                    scannedText.iCloudRecordName = record.recordID.recordName
                                    save()
                                    print("Record aggiunto sul CoreData : " + scannedText.iCloudRecordName!)
                                }
                            }
                        }
                        NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil)
                    }
                }
            }else{
                print("Can't access iCloud")
        }
        
        
        
    }
    
    static func desyncWithiCloud() -> Void{
        
        print("DESYNCHING.....................")
        let context = getContext()
        
        var scannedTexts = [ScannedText]()
        let fetchRequest = NSFetchRequest<ScannedText>(entityName : name)
        
        do {
            scannedTexts = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.code)")
        }
        
        for scannedText in scannedTexts {
            if scannedText.isIniCloud {
                scannedText.isIniCloud = false
            }
        }
    }
    
    static func deleteAllFromiCloud() -> Void{
        CKContainer.default().accountStatus{(status:CKAccountStatus,error:Error?) in
            if status == .available{
                let privateDatabase = CKContainer.default().privateCloudDatabase

                let query = CKQuery(recordType: "ScannedText", predicate: NSPredicate(format: "TRUEPREDICATE"))
                privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                    if error == nil {
                        for record in records! {
                            privateDatabase.delete(withRecordID: record.recordID, completionHandler: { (recordId, error) in
                                if error == nil {
                                    print("Record eliminato\n    ")
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    static func iCloudChecker() -> Bool{
        
        var available = false
    
        if !Reachability.isConnectedToNetwork(){
            UserDefaults.standard.set(false, forKey: "iCloudEnabled")
            available = false
//            print("Unavailable")
        }else{
            let group = DispatchGroup()
            group.enter()
            // avoid deadlocks by not using .main queue here
            DispatchQueue.global(qos: .default).async{
            
            CKContainer.default().accountStatus{(status:CKAccountStatus,error:Error?) in
                if error == nil{
                    if status != .available{
                        UserDefaults.standard.set(false, forKey: "iCloudEnabled")
                        available = false
//                        print("Unavailable")
                    }else{
                        UserDefaults.standard.set(UserDefaults.standard.bool(forKey: "iCloudEnabled"), forKey: "iCloudEnabled")
                        available = true
//                        print("Available")
                    }
                }else{
                    print(error as Any)
                }
                group.leave()
            }
        }
        
        // wait ...
        group.wait()
        }
        // ... and return as soon as "temp" has a value
        return available
        }

}
