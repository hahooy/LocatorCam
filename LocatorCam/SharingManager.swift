//
//  SharingManager.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/20/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import Foundation
import UIKit

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
    var momentsUpdateHandlers = Array<((Void) -> Void)>()
    // all moments download from the database
    var moments = [Moment]() {
        didSet {
            for handler in momentsUpdateHandlers {
                handler()
            }
        }
    }
    let defaults = UserDefaults.standard
    let semaphore = DispatchSemaphore(value: 1)
    
    // determine if the picture will be stamped by location and time data
    var locationStampEnabled: Bool {
        get {
            if defaults.object(forKey: "locationStampEnabled") == nil {
                return true
            }
            return defaults.bool(forKey: "locationStampEnabled")
        }
        
        set {
            defaults.set(newValue, forKey: "locationStampEnabled")
        }
    }
    
    struct Constant {
        static let NumberOfMomentsToFetch: UInt = 10
        static let minimumTimeInterval = 0.000001
        static let maxThumbnailSize: CGFloat = 1000
        //static let baseServerURL = "http://127.0.0.1:8000/locator-cam/"
        static let baseServerURL = "https://locatorcam.herokuapp.com/locator-cam/"
        static let loginURL = baseServerURL + "login/"
        static let searchUserURL = baseServerURL + "search-user/"
        static let addFriendURL = baseServerURL + "add-friend/"
        static let numberOfFriendsURL = baseServerURL + "number-of-friends/"
        static let getAllFriendsURL = baseServerURL + "get-all-friends/"
        static let unfriendURL = baseServerURL + "unfriend/"
        static let uploadMomentURL = baseServerURL + "upload-moment/"
        static let fetchMomentsURL = baseServerURL + "fetch-moments/"
        static let fetchPhotoURL = baseServerURL + "fetch-photo/"
        static let logoutURL = baseServerURL + "logout/"
        static let fetchChannelURL = baseServerURL + "fetch-channels/"
        static let fetchChannelsCountURL = baseServerURL + "fetch-channels-count/"
        static let addMemberToChannelURL = baseServerURL + "add-member-to-channel/"
        static let createChannelURL = baseServerURL + "create-channel/"
        static let addAdministratorsToChannelURL = baseServerURL + "add-administrator-to-channel/"
        static let getChannelMembersURL = baseServerURL + "get-channel-members/"
        static let getChannelAdministratorsURL = baseServerURL + "get-channel-administrators/"
        static let removeMemberFromChannelURL = baseServerURL + "remove-member-from-channel/"
        static let removeAdministratorFromChannelURL = baseServerURL + "remove-administrator-from-channel/"
        static let deleteChannelURL = baseServerURL + "delete-channel/"
        static let leaveChannelURL = baseServerURL + "leave-channel/"
    }

    
    // add a handler for updating moments
    func addMomentsUpdatedHandler(_ handler: @escaping (Void) -> Void) {
        momentsUpdateHandlers.append(handler)
    }
    
    
    func fetchMoments(publishedEarlier: Bool, publishedLater: Bool, spinner: UIActivityIndicatorView?, refreshControl: UIRefreshControl?) {
        // run the whole fetching process on a different queue to
        // avoid blocking the main queue
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
            // use semaphore to avoid moments array being updated by multiple threads
            let timeout = DispatchTime.now() + Double(2 * 60 * 1000 * 1000 * 1000) / Double(NSEC_PER_SEC)
            _ = self.semaphore.wait(timeout: timeout)
            // fetch moments happened before endTime
            // make API request to upload the photo
            let url:URL = URL(string: SharingManager.Constant.fetchMomentsURL)!
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            var param: [String: AnyObject] = ["content_type": "JSON" as AnyObject]
            
            // specify the time condition for the request
            if publishedEarlier == true {
                param["published_earlier_than"] = true as AnyObject?
            }
            if publishedLater == true {
                param["published_later_than"] = true as AnyObject?
            }
            
            // is the user in a channel?
            if let channelID = UserInfo.currentChannel?.id {
                param["channel_id"] = channelID as AnyObject?
            }
            
            var existingMomentID: [Int] = []
            for moment in self.moments {
                existingMomentID.append(moment.id!)
            }
            param["existing_moments_id"] = existingMomentID as AnyObject?
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if spinner != nil {
                DispatchQueue.main.async(execute: {
                    spinner!.startAnimating()
                })
            }
            
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error: \(error)")
                    return
                }
                
                do {
                    let momentsJSON = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]]
                    var tempMoments = [Moment]()
                    
                    for moment in momentsJSON {
                        
                        let tempMoment = Moment()
                        if let id = moment["id"] as? Int {
                            tempMoment.id = id
                        }
                        if let username = moment["username"] as? String {
                            tempMoment.username = username
                        }
                        if let description = moment["description"] as? String {
                            tempMoment.description = description
                        }
                        if let latitude = moment["latitude"] as? Double {
                            tempMoment.latitude = latitude
                        }
                        if let longitude = moment["longitude"] as? Double {
                            tempMoment.longitude = longitude
                        }
                        if let pub_time_interval = moment["pub_time_interval"] as? TimeInterval {
                            tempMoment.pub_time_interval = pub_time_interval
                        }
                        if let thumbnail_base64 = moment["thumbnail_base64"] as? String {
                            tempMoment.thumbnail_base64 = thumbnail_base64
                        }
                        tempMoments.append(tempMoment)
                    }
                    if tempMoments.count > 0 {
                        print(tempMoments[0].pub_time_interval!)
                    }
                    DispatchQueue.main.async(execute: {
                        if publishedLater == true {
                            self.moments = tempMoments + self.moments
                        } else {
                            self.moments += tempMoments
                        }
                    })
                } catch {
                    print("error serializing JSON: \(error)")
                }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if spinner != nil {
                        spinner!.stopAnimating()
                    }
                    if refreshControl != nil {
                        refreshControl?.endRefreshing()
                    }
                })
                self.semaphore.signal()
            }) 
            task.resume()
        }
    }
}
