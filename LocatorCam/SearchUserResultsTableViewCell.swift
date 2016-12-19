//
//  SearchUserResultsTableViewCell.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/4/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class SearchUserResultsTableViewCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userdescription: UILabel!
    @IBAction func addFriend(_ sender: UIButton) {
        if let username = username.text {
            addFriend(username)
        }
    }
    
    weak var searchTableViewController: SearchTableViewController?
    
    fileprivate func addFriend(_ username: String) {
        
        let url:URL = URL(string: SharingManager.Constant.addFriendURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "username=\(username)&content_type=JSON"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
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
                        let addFriendAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        addFriendAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                        if let tableViewController = self.searchTableViewController {
                            tableViewController.present(addFriendAlert, animated: true, completion: nil)
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
