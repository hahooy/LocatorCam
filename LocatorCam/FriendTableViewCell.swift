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

    @IBAction func unfriendButtonAction(_ sender: UIButton) {
        let unfriendAllert = UIAlertController(title: nil, message: "Unfollow \(friendUsernameLabel.text!)?", preferredStyle: .actionSheet)
        unfriendAllert.addAction(UIAlertAction(title: "Unfriend", style: .destructive, handler: {(action: UIAlertAction) -> Void in self.unfriend(self.friendUsernameLabel.text!) } ))
        unfriendAllert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if friendTableViewController != nil {
            friendTableViewController!.present(unfriendAllert, animated: true, completion: nil)
        }
    }
    
    weak var friendTableViewController: UsersListTableViewController?
    
    // MARK: - API Requests
    fileprivate func unfriend(_ username: String) {
        let url:URL = URL(string: SharingManager.Constant.unfriendURL)!
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
                    print(message)
                    DispatchQueue.main.async(execute: {
                        self.friendTableViewController!.getAllFriends()
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()
    }
}
