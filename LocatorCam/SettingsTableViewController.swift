//
//  SettingsTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/16/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet weak var stampLocationSwitch: UISwitch!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var numberOfFriendsButton: UIButton!
    @IBOutlet weak var numberOfChannelsButton: UIButton!
    @IBAction func numberOfFriendsButtonAction(sender: UIButton) {
        
    }
    @IBAction func logout(sender: UIBarButtonItem) {
        logoutUser()
    }
    
    struct Constant {
        static let toLogin = "to login"
        static let toFriends = "from settings to friends"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stampLocationSwitch.setOn(SharingManager.sharedInstance.locationStampEnabled, animated: false)
        usernameLabel.text = UserInfo.username
        emailLabel.text = UserInfo.email
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbarHidden = true
        getNumberOfFriends()
        getNumOfChannels()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.toolbarHidden = false
        SharingManager.sharedInstance.locationStampEnabled = stampLocationSwitch.on
    }
    
    private func getNumberOfFriends() {
        let url:NSURL = NSURL(string: SharingManager.Constant.numberOfFriendsURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "content_type=JSON"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                if let numberOfFriends = json["number_of_friends"] as? Int {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.numberOfFriendsButton.setTitle(String(numberOfFriends), forState: .Normal)
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    private func getNumOfChannels() {
        let url:NSURL = NSURL(string: SharingManager.Constant.fetchChannelsCountURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                if let numberOfChannels = json["channels_count"] as? Int {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.numberOfChannelsButton.setTitle(String(numberOfChannels), forState: .Normal)
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
        
    }
    
    private func logoutUser() {
        let url:NSURL = NSURL(string: SharingManager.Constant.loginURL)!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
        }
        task.resume()
        
        // cleanup
        
        UserInfo.email = nil
        UserInfo.friends = nil
        UserInfo.username = nil
        
        SharingManager.sharedInstance.moments = [Moment]()
        SharingManager.sharedInstance.momentsUpdateHandlers = Array<(Void -> Void)>()
        
        performSegueWithIdentifier(Constant.toLogin, sender: self)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constant.toFriends {
            if let userTable = segue.destinationViewController as? UsersListTableViewController {
                userTable.userType = UsersListTableViewController.UserType.Friend
            }
        }
    }
}
