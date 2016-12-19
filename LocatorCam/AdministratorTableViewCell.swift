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
    
    @IBAction func removeAdministratorButton(_ sender: AnyObject) {
        if let name = nameLabel.text, let channelID = usersListTableViewController?.channel?.id, let userType = usersListTableViewController?.userType {

            if userType == .admin {
                removeUserFromChannel(name, channelID: channelID, requestURL: SharingManager.Constant.removeAdministratorFromChannelURL, usernameType: "administrator_username")
            } else if userType == .member {
                removeUserFromChannel(name, channelID: channelID, requestURL: SharingManager.Constant.removeMemberFromChannelURL, usernameType: "member_username")
            }            
        }
    }
    
    fileprivate func removeUserFromChannel(_ username: String, channelID: Int, requestURL: String, usernameType: String) {
        
        let url:URL = URL(string: requestURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let param: [String: AnyObject] = ["channel_id": channelID as AnyObject, usernameType: username as AnyObject]
        
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
                        if let tableViewController = self.usersListTableViewController {
                            tableViewController.present(inviteUserAlert, animated: true, completion: nil)
                            tableViewController.viewWillAppear(true)
                        }
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()
    }
    
}
