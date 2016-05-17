//
//  measuringReferenceTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/16/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class measuringReferenceTableViewController: UITableViewController {
    
    let measuringReferences = [("Drivers License", 3, "Inches"), ("4 Inches", 4, "Inches")]
    var selectedCellRow = 0
    struct Constant {
        static let reusableCellIdentifier = "name and length"
        static let unwindSegueToEditPhoto = "unwind to edit photo"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measuringReferences.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.reusableCellIdentifier, forIndexPath: indexPath)
        let reference = measuringReferences[indexPath.row]
        cell.textLabel?.text = reference.0
        cell.detailTextLabel?.text = "\(reference.1) \(reference.2)"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCellRow = indexPath.row
        performSegueWithIdentifier(Constant.unwindSegueToEditPhoto, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constant.unwindSegueToEditPhoto {            
            if let editPhotoViewController = segue.destinationViewController as? EditPhotoVC {
                editPhotoViewController.measuringReference = measuringReferences[selectedCellRow]
            }
        }
    }
    
    
}
