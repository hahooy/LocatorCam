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
    @IBAction func createChannelButton(_ sender: UIButton) {
        if let channelName = channelNameTextField.text {
            createChannel(channelName, description: channelDescriptionTextField.text)
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        channelNameTextField.resignFirstResponder()
        channelDescriptionTextField.resignFirstResponder()
    }
    
    // MARK: - API Requests
    fileprivate func createChannel(_ channelName: String, description: String?) {
        let url:URL = URL(string: SharingManager.Constant.createChannelURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var param: [String: AnyObject] = ["channel_name": channelName as AnyObject]
        if let description = description {
            param["channel_description"] = description as AnyObject?
        }
        
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
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()
    }
    
}
