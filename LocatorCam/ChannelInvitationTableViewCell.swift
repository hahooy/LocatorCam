//
//  ChannelInvitationTableViewCell.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/25/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class ChannelInvitationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
   
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    @IBAction func inviteButton(_ sender: UIButton) {
        if let username = name.text, let id = channelID {
            invite(username, channelID: id)
        }
    }
    
    var channelID: Int?
    var channelInvitationTableViewController: ChannelInvitationTableViewController?
    
    fileprivate func invite(_ username: String, channelID: Int) {
        
        let url:URL = URL(string: SharingManager.Constant.addMemberToChannelURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let param: [String: AnyObject] = ["username_to_be_added": username as AnyObject, "channel_id": channelID as AnyObject]
        
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
                        if let tableViewController = self.channelInvitationTableViewController {
                            tableViewController.present(inviteUserAlert, animated: true, completion: nil)
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
