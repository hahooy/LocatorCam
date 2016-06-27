//
//  AdministratorTableViewCell.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/26/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class AdministratorTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    weak var usersListTableViewController: UsersListTableViewController?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func removeAdministratorButton(sender: AnyObject) {
        if let name = nameLabel.text, let channelID = usersListTableViewController?.channel?.id, let userType = usersListTableViewController?.userType {

            if userType == .Admin {
                removeUserFromChannel(name, channelID: channelID, requestURL: SharingManager.Constant.removeAdministratorFromChannelURL, usernameType: "administrator_username")
            } else if userType == .Member {
                removeUserFromChannel(name, channelID: channelID, requestURL: SharingManager.Constant.removeMemberFromChannelURL, usernameType: "member_username")
            }            
        }
    }
    
    private func removeUserFromChannel(username: String, channelID: Int, requestURL: String, usernameType: String) {
        
        let url:NSURL = NSURL(string: requestURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let param: [String: AnyObject] = ["channel_id": channelID, usernameType: username]
        
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
                
                if let message = json["message"] as? String {
                    dispatch_async(dispatch_get_main_queue(), {
                        let inviteUserAlert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                        inviteUserAlert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                        if let tableViewController = self.usersListTableViewController {
                            tableViewController.presentViewController(inviteUserAlert, animated: true, completion: nil)
                            tableViewController.viewWillAppear(true)
                        }
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
    }
    
}
