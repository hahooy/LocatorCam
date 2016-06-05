//
//  FriendsTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/4/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {

    // MARK: - Properties
    private var friends: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    struct Constant {
        static let friendCellIdentifier = "friend cell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllFriends()
        self.navigationController?.toolbarHidden = true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.friendCellIdentifier, forIndexPath: indexPath)
        if let cell = cell as? FriendTableViewCell {
            cell.friendUsernameLabel.text = friends[indexPath.row]
            cell.friendTableViewController = self
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
                        self.friends = friends
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
    }

}
