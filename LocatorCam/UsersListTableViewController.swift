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
    fileprivate var users: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    enum UserType {
        case friend
        case member
        case admin
    }
    
    var userType: UserType?
    var channel: Channel?
    
    struct Constant {
        static let friendCellIdentifier = "friend cell"
        static let administratorCellIdentifier = "administrator cell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let type = userType {
            switch type {
            case .friend:
                self.title = "Friends"
                getAllFriends()
            case .admin:
                self.title = "Administrators"
                if let channelID = channel?.id {
                    getUsersFromChannel(channelID, requestURL: SharingManager.Constant.getChannelAdministratorsURL, typeKey: "administrators")
                }
            case .member:
                self.title = "Members"
                if let channelID = channel?.id {
                    getUsersFromChannel(channelID, requestURL: SharingManager.Constant.getChannelMembersURL, typeKey: "members")
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = ""
        if let type = userType {
            switch type {
            case .friend:
                identifier = Constant.friendCellIdentifier
            case .admin, .member:
                identifier = Constant.administratorCellIdentifier
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
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
        let url:URL = URL(string: SharingManager.Constant.getAllFriendsURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "content_type=JSON"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                if let friends = json["friends"] as? [String] {
                    DispatchQueue.main.async(execute: {
                        self.users = friends
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()
    }
    
    fileprivate func getUsersFromChannel(_ channelID: Int, requestURL: String, typeKey: String) {
        
        let url:URL = URL(string: requestURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let param: [String: AnyObject] = ["channel_id": channelID as AnyObject]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        } catch {
            print("error serializing JSON: \(error)")
        }
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                
                if let users = json[typeKey] as? [String] {
                    DispatchQueue.main.async(execute: {
                        self.users = users
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()
    }
    
    
}
