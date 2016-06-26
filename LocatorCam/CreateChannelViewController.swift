//
//  CreateChannelViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/25/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class CreateChannelViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var EnablePrivateChannelSwitch: UISwitch!
    @IBOutlet weak var channelNameTextField: UITextField!
    @IBOutlet weak var channelDescriptionTextField: UITextField!
    @IBAction func createChannelButton(sender: UIButton) {
        if let channelName = channelNameTextField.text {
            createChannel(channelName, description: channelDescriptionTextField.text)
        }
    }
    
    // MARK: - API Requests
    private func createChannel(channelName: String, description: String?) {
        let url:NSURL = NSURL(string: SharingManager.Constant.createChannelURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var param: [String: AnyObject] = ["channel_name": channelName]
        if let description = description {
            param["channel_description"] = description
        }
        
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
