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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
        fetchChannels()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.leftDetailChannelCellIdentifier, for: indexPath)
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
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: Constant.toChannelSettingsSegueIdentifier, sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // user switch channel, refetch all the moments
        UserInfo.currentChannel = channels[indexPath.row]
        SharingManager.sharedInstance.moments = [Moment]()
        _ = navigationController?.popViewController(animated: true)
    }
    

    // MARK: - API Requests
    
    func fetchChannels() {
        // make API request to fetch all channels
        let url:URL = URL(string: SharingManager.Constant.fetchChannelURL)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let channelsJSON = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]]
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
                
                DispatchQueue.main.async(execute: {
                    self.channels = tempChannels
                })
            } catch {
                print("error serializing JSON: \(error)")
            }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }) 
        task.resume()
    }



    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let channelSettingsVC = segue.destination as? ChannelSettingsTableViewController, let indexPath = sender as? IndexPath {
            let channel = channels[indexPath.row]
            channelSettingsVC.channel = channel
        }
    }

}
