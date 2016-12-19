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
        static let minimumNumberOfSearchCharacters = 2
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
    func updateSearchResults(for searchController: UISearchController) {
        let searchKeyword = searchController.searchBar.text!
        
        // set the minimum number of search characters to 2
        if searchKeyword.characters.count < Constant.minimumNumberOfSearchCharacters {
            return
        }
        let searchScope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
        searchRequest(searchKeyword, scope: searchScope)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.userResultCellIdentifier, for: indexPath)
        if let cell = cell as? SearchUserResultsTableViewCell {
            cell.username.text = searchResults[indexPath.row]
            cell.userdescription.text = ""
            cell.searchTableViewController = self
        }
        return cell
    }
    
    // MARK: - Search Methods
    fileprivate func searchRequest(_ keyword: String, scope: String) {
        if scope == Constant.SearchScope.People.rawValue {
            let url:URL = URL(string: SharingManager.Constant.searchUserURL)!
            let session = URLSession.shared
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            
            let paramString = "username=\(keyword)&content_type=JSON"
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error: \(error)")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    if let users = json["users"] as? [String] {                        
                        DispatchQueue.main.async(execute: {
                            self.searchResults = users
                        })
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }) 
            task.resume()
        }
    }
}
