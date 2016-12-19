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
    @IBAction func numberOfFriendsButtonAction(_ sender: UIButton) {
        
    }
    @IBAction func logout(_ sender: UIBarButtonItem) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
        getNumberOfFriends()
        getNumOfChannels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isToolbarHidden = false
        SharingManager.sharedInstance.locationStampEnabled = stampLocationSwitch.isOn
    }
    
    fileprivate func getNumberOfFriends() {
        let url:URL = URL(string: SharingManager.Constant.numberOfFriendsURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "content_type=JSON"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                if let numberOfFriends = json["number_of_friends"] as? Int {
                    DispatchQueue.main.async(execute: {
                        self.numberOfFriendsButton.setTitle(String(numberOfFriends), for: UIControlState())
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()
    }
    
    fileprivate func getNumOfChannels() {
        let url:URL = URL(string: SharingManager.Constant.fetchChannelsCountURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                if let numberOfChannels = json["channels_count"] as? Int {
                    DispatchQueue.main.async(execute: {
                        self.numberOfChannelsButton.setTitle(String(numberOfChannels), for: UIControlState())
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()
        
    }
    
    fileprivate func logoutUser() {
        let url:URL = URL(string: SharingManager.Constant.loginURL)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
        }) 
        task.resume()
        
        // cleanup
        
        UserInfo.email = nil
        UserInfo.friends = nil
        UserInfo.username = nil
        
        SharingManager.sharedInstance.moments = [Moment]()
        SharingManager.sharedInstance.momentsUpdateHandlers = Array<((Void) -> Void)>()
        
        performSegue(withIdentifier: Constant.toLogin, sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.toFriends {
            if let userTable = segue.destination as? UsersListTableViewController {
                userTable.userType = UsersListTableViewController.UserType.friend
            }
        }
    }
}
