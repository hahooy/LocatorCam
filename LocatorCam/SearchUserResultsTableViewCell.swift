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
    @IBAction func addFriend(sender: UIButton) {
        if let username = username.text {
            addFriend(username)
        }
    }
    
    weak var searchTableViewController: SearchTableViewController?
    
    private func addFriend(username: String) {
        
        let url:NSURL = NSURL(string: SharingManager.Constant.addFriendURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "username=\(username)&content_type=JSON"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
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
                        let addFriendAlert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                        addFriendAlert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                        if let tableViewController = self.searchTableViewController {
                            tableViewController.presentViewController(addFriendAlert, animated: true, completion: nil)
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
