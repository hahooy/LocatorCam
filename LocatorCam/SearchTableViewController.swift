//
//  SearchResultsTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/3/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController,UISearchBarDelegate,UISearchResultsUpdating {
    
    // MARK: - Properties
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchResults: [String] = [] {
        didSet {
            print("reload data")
            self.tableView.reloadData()
        }
    }
    
    struct Constant {
        enum SearchScope: String {
            case People = "People"
            case Moments = "Moments"
            case Other = "Other"
        }
        static let userResultCellIdentifier = "user"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // avoid overlapping the status bar
        tableView.contentInset.top = 20
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = [Constant.SearchScope.People.rawValue, Constant.SearchScope.Moments.rawValue, Constant.SearchScope.Other.rawValue]
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - UISearchResultsUpdating Protocol Method
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("updating")
        let searchKeyword = searchController.searchBar.text!
        let searchScope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
        searchRequest(searchKeyword, scope: searchScope)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.userResultCellIdentifier, forIndexPath: indexPath)
        if let cell = cell as? SearchUserResultsTableViewCell {
            cell.username.text = searchResults[indexPath.row]
            cell.userdescription.text = ""
            cell.searchTableViewController = self
        }
        return cell
    }
    
    // MARK: - Search Methods
    private func searchRequest(keyword: String, scope: String) {
        if scope == Constant.SearchScope.People.rawValue {
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
}
