//
//  SharingManager.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/20/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import Foundation
import Firebase

/*
 This class contains variables that are shared across the entire application
 */

class SharingManager {
    
    /*
     singleton instance of SharingManager, this instance is shared among the whole application
     */
    static let sharedInstance = SharingManager()
    /*
     handlers to be executed whenever moments get updated. usually the handler is a closure that
     refresh the UIView
     */
    var momentsUpdateHandlers = Array<(Void -> Void)>()
    // all moments download from the database
    var moments = [NSDictionary]() {
        didSet {
            for handler in momentsUpdateHandlers {
                handler()
            }
        }
    }
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // determine if the picture will be stamped by location and time data
    var locationStampEnabled: Bool {
        get {
            if defaults.objectForKey("locationStampEnabled") == nil {
                return true
            }
            return defaults.boolForKey("locationStampEnabled")
        }
        
        set {
            defaults.setBool(newValue, forKey: "locationStampEnabled")
        }
    }
    
    struct Constant {
        static let NumberOfMomentsToFetch: UInt = 10
        static let minimumTimeInterval = 0.000001
        static let thumbnailWidth: CGFloat = 1000
    }
    
    init() {
        initFirebase(NSDate().timeIntervalSince1970)
    }
    
    // add a handler for updating moments
    func addMomentsUpdatedHandler(handler: Void -> Void) {
        momentsUpdateHandlers.append(handler)
    }
    
    // initialize firebase, load the initial data set, register firebase event listener
    func initFirebase(time: NSTimeInterval) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        // fetch initial data set, this will be run only once
        DataBase.momentFirebaseRef.queryOrderedByChild("time").queryEndingAtValue(time).queryLimitedToLast(SharingManager.Constant.NumberOfMomentsToFetch).observeSingleEventOfType(.Value, withBlock: { snapshot in
            var tempMoments = [NSDictionary]()
            
            for moment in snapshot.children {
                let child = moment as! FDataSnapshot
                let dict = child.value as! NSDictionary
                tempMoments.append(dict)
            }
            
            SharingManager.sharedInstance.moments += tempMoments.reverse()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        // if new data is added to the database, insert it to moments
        DataBase.momentFirebaseRef.queryOrderedByChild("time").queryStartingAtValue(time + Constant.minimumTimeInterval).observeEventType(.ChildAdded, withBlock: { snapshot in
            if let dict = snapshot.value as? NSDictionary {
                SharingManager.sharedInstance.moments.insert(dict, atIndex: 0)
            }
        })
    }
    
    // load more data from firebase, data is appended to the moments array in shared instance
    func loadDataFromFirebase(time: NSTimeInterval, spinner: UIActivityIndicatorView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        DataBase.momentFirebaseRef.queryOrderedByChild("time").queryEndingAtValue(time).queryLimitedToLast(SharingManager.Constant.NumberOfMomentsToFetch).observeSingleEventOfType(.Value, withBlock: { snapshot in
            var tempMoments = [NSDictionary]()
            
            for moment in snapshot.children {
                let child = moment as! FDataSnapshot
                let dict = child.value as! NSDictionary
                tempMoments.append(dict)
            }
            
            SharingManager.sharedInstance.moments += tempMoments.reverse()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            spinner.stopAnimating()
        })
    }
    
    // add moment to firebase
    func addMoment(ref: Firebase, data: NSDictionary) {
        ref.setValue(data)
    }
    
    // add photo to firebase
    func addPhoto(ref: Firebase, base64String: NSString) {
        ref.setValue(base64String)
    }
}
