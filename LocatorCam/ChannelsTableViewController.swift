//
//  ChannelsTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/19/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class ChannelsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var channels:[Channel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    struct Constant {
        static let leftDetailChannelCellIdentifier = "left detail channel cell"
        static let toChannelSettingsSegueIdentifier = "to channel settings"        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbarHidden = true
        fetchChannels()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.leftDetailChannelCellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = channels[indexPath.row].name
        var detailText = "This channel has no member"
        if let numOfMembers = channels[indexPath.row].numOfMembers {
            if numOfMembers == 1 {
                detailText = "1 member"
            } else {
                detailText = "\(numOfMembers) members"
            }
        }
        cell.detailTextLabel?.text = detailText
        return cell
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constant.toChannelSettingsSegueIdentifier, sender: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // user switch channel, refetch all the moments
        UserInfo.currentChannel = channels[indexPath.row]
        SharingManager.sharedInstance.moments = [Moment]()
        navigationController?.popViewControllerAnimated(true)
    }
    

    // MARK: - API Requests
    
    func fetchChannels() {
        // make API request to fetch all channels
        let url:NSURL = NSURL(string: SharingManager.Constant.fetchChannelURL)!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let channelsJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSArray
                var tempChannels = [Channel]()
                
                for channel in channelsJSON {
                    
                    let tempChannel = Channel()
                    if let id = channel["channel_id"] as? Int {
                        tempChannel.id = id
                    }
                    if let name = channel["channel_name"] as? String {
                        tempChannel.name = name
                    }
                    if let description = channel["description"] as? String {
                        tempChannel.description = description
                    }
                    if let numOfMembers = channel["num_members"] as? Int {
                        tempChannel.numOfMembers = numOfMembers
                    }
                    if let numOfAdmins = channel["num_admins"] as? Int {
                        tempChannel.numOfAdmins = numOfAdmins
                    }
                    tempChannels.append(tempChannel)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.channels = tempChannels
                })
            } catch {
                print("error serializing JSON: \(error)")
            }
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
        task.resume()
    }



    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let channelSettingsVC = segue.destinationViewController as? ChannelSettingsTableViewController, let indexPath = sender as? NSIndexPath {
            let channel = channels[indexPath.row]
            channelSettingsVC.channel = channel
        }
    }

}
