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
    @IBAction func leaveChannelButton(_ sender: UIButton) {
        if let channelID = channel?.id {
            makeChannelRequest(channelID, url: SharingManager.Constant.leaveChannelURL)
        }
    }
    @IBAction func deleteChannelButton(_ sender: UIButton) {
        if let channelID = channel?.id {
            makeChannelRequest(channelID, url: SharingManager.Constant.deleteChannelURL)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case Constant.segueToSearchUserIdentifier:
            if let searchUserVC = segue.destination as? ChannelInvitationTableViewController {
                searchUserVC.channelToJoin = channel
            }
        case Constant.segueToAdministrators:
            if let usersListVC = segue.destination as? UsersListTableViewController {
                usersListVC.userType = UsersListTableViewController.UserType.admin
                usersListVC.channel = channel
            }
        case Constant.segueToMembers:
            if let usersListVC = segue.destination as? UsersListTableViewController {
                usersListVC.userType = UsersListTableViewController.UserType.member
                usersListVC.channel = channel
            }
        default:
            return
        }
    }
    
    fileprivate func makeChannelRequest(_ channelID: Int, url: String) {
        
        let url:URL = URL(string: url)!
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
                
                if let message = json["message"] as? String {
                    DispatchQueue.main.async(execute: {
                        let inviteUserAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        inviteUserAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                        self.present(inviteUserAlert, animated: true, completion: nil)
                    })
                }
                
                UserInfo.currentChannel = nil
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()
    }
    
}
