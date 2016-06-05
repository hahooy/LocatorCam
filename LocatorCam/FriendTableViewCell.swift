//
//  FriendTableViewCell.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/4/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var friendUsernameLabel: UILabel!

    @IBAction func unfriendButtonAction(sender: UIButton) {
        let unfriendAllert = UIAlertController(title: nil, message: "Unfollow \(friendUsernameLabel.text!)?", preferredStyle: .ActionSheet)
        unfriendAllert.addAction(UIAlertAction(title: "Unfriend", style: .Destructive, handler: {(action: UIAlertAction) -> Void in self.unfriend(self.friendUsernameLabel.text!) } ))
        unfriendAllert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        if friendTableViewController != nil {
            friendTableViewController!.presentViewController(unfriendAllert, animated: true, completion: nil)
        }
    }
    
    weak var friendTableViewController: FriendsTableViewController?
    
    // MARK: - API Requests
    private func unfriend(username: String) {
        let url:NSURL = NSURL(string: SharingManager.Constant.unfriendURL)!
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
                    print(message)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.friendTableViewController!.getAllFriends()
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
    }
}
