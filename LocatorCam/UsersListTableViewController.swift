//
//  FriendsTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/4/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class UsersListTableViewController: UITableViewController {
    
    // MARK: - Properties
    private var users: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    enum UserType {
        case Friend
        case Member
        case Admin
    }
    
    var userType: UserType?
    var channel: Channel?
    
    struct Constant {
        static let friendCellIdentifier = "friend cell"
        static let administratorCellIdentifier = "administrator cell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.toolbarHidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        if let type = userType {
            switch type {
            case .Friend:
                self.title = "Friends"
                getAllFriends()
            case .Admin:
                self.title = "Administrators"
                if let channelID = channel?.id {
                    getUsersFromChannel(channelID, requestURL: SharingManager.Constant.getChannelAdministratorsURL, typeKey: "administrators")
                }
            case .Member:
                self.title = "Members"
                if let channelID = channel?.id {
                    getUsersFromChannel(channelID, requestURL: SharingManager.Constant.getChannelMembersURL, typeKey: "members")
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier = ""
        if let type = userType {
            switch type {
            case .Friend:
                identifier = Constant.friendCellIdentifier
            case .Admin, .Member:
                identifier = Constant.administratorCellIdentifier
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        if let cell = cell as? FriendTableViewCell {
            cell.friendUsernameLabel.text = users[indexPath.row]
            cell.friendTableViewController = self
        } else if let cell = cell as? AdministratorTableViewCell {
            cell.nameLabel.text = users[indexPath.row]
            cell.usersListTableViewController = self
        }
        
        return cell
    }
    
    
    // MARK: - API Requests
    func getAllFriends() {
        let url:NSURL = NSURL(string: SharingManager.Constant.getAllFriendsURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "content_type=JSON"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                if let friends = json["friends"] as? [String] {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.users = friends
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    private func getUsersFromChannel(channelID: Int, requestURL: String, typeKey: String) {
        
        let url:NSURL = NSURL(string: requestURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let param: [String: AnyObject] = ["channel_id": channelID]
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(param, options: .PrettyPrinted)
        } catch {
            print("error serializing JSON: \(error)")
        }
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                if let users = json[typeKey] as? [String] {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.users = users
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    
}
