//
//  ChannelInvitationTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/25/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class ChannelInvitationTableViewController: UITableViewController, UISearchBarDelegate,UISearchResultsUpdating {
    
    // MARK: - Properties
    var channelToJoin: Channel?
    let searchController = UISearchController(searchResultsController: nil)
    var searchResults: [String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    struct Constant {
        static let inviteUserResultCellIdentifier = "invite user to channel cell"
        static let minimumNumberOfSearchCharacters = 2
    }
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - UISearchResultsUpdating Protocol Method
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchKeyword = searchController.searchBar.text!
        
        // set the minimum number of search characters to 2
        if searchKeyword.characters.count < Constant.minimumNumberOfSearchCharacters {
            return
        }

        searchRequest(searchKeyword)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.inviteUserResultCellIdentifier, forIndexPath: indexPath)
        if let cell = cell as? ChannelInvitationTableViewCell {
            cell.name.text = searchResults[indexPath.row]
            cell.userDescription.text = ""
            cell.channelID = channelToJoin!.id
            cell.channelInvitationTableViewController = self
        }
        return cell
    }
    
    // MARK: - Search Methods
    private func searchRequest(keyword: String) {
        
        let url:NSURL = NSURL(string: SharingManager.Constant.searchUserURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "username=\(keyword)&content_type=JSON"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                if let users = json["users"] as? [String] {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.searchResults = users
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
    }

}
