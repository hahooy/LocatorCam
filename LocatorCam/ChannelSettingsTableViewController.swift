//
//  ChannelSettingsTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/19/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class ChannelSettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var channel: Channel?
    
    struct Constant {
        static let segueToSearchUserIdentifier = "to search user for invitation"
        static let segueToAdministrators = "from channel settings to administrator list"
        static let segueToMembers = "from channel settings to member list"
    }
    
    @IBOutlet weak var channelTitleLable: UILabel!
    @IBOutlet weak var channelDescriptionLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var numberOfAdministratorsLabel: UILabel!
    
    @IBAction func deleteChannelButton(sender: UIButton) {
        if let channelID = channel?.id {
            deleteChannel(channelID)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        channelTitleLable.text = channel?.name
        channelDescriptionLabel.text = channel?.description
        if let numOfAdmins = channel?.numOfAdmins {
            numberOfAdministratorsLabel.text = "\(numOfAdmins)"
        }
        if let numOfMembers = channel?.numOfMembers {
            numberOfMembersLabel.text = "\(numOfMembers)"
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case Constant.segueToSearchUserIdentifier:
            if let searchUserVC = segue.destinationViewController as? ChannelInvitationTableViewController {
                searchUserVC.channelToJoin = channel
            }
        case Constant.segueToAdministrators:
            if let usersListVC = segue.destinationViewController as? UsersListTableViewController {
                usersListVC.userType = UsersListTableViewController.UserType.Admin
                usersListVC.channel = channel
            }
        case Constant.segueToMembers:
            if let usersListVC = segue.destinationViewController as? UsersListTableViewController {
                usersListVC.userType = UsersListTableViewController.UserType.Member
                usersListVC.channel = channel
            }
        default:
            return
        }
    }
    
    private func deleteChannel(channelID: Int) {
        
        let url:NSURL = NSURL(string: SharingManager.Constant.deleteChannelURL)!
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
                
                if let message = json["message"] as? String {
                    dispatch_async(dispatch_get_main_queue(), {
                        let inviteUserAlert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                        inviteUserAlert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))                        
                        self.presentViewController(inviteUserAlert, animated: true, completion: nil)
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    
}
