//
//  measuringReferenceTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/16/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class measuringReferenceTableViewController: UITableViewController {
    
    let measuringReferences: [(String, Float, String)] = [("Drivers License (width)", 3.375, "inches"), ("Drivers License (length)", 3.622, "inches"), ("iPhone 5 (height)", 4.87, "inches"), ("iPhone 5 (width)", 2.31, "inches"), ("iPhone 6 (height)", 5.44, "inches"), ("iPhone 6 plus (height)", 6.22, "inches")]
    var selectedCellRow = 0
    struct Constant {
        static let predefinedLengthCell = "predefined length"
        static let customLengthCell = "custom length"
        static let unwindFromPredefinedReference = "unwind from predefined reference to edit board"
        static let unwindFromCustomReference = "unwind from custom reference to edit board"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return measuringReferences.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Predefined"
        } else if section == 1 {
            return "Custom"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.predefinedLengthCell, forIndexPath: indexPath)
            let reference = measuringReferences[indexPath.row]
            cell.textLabel?.text = reference.0
            cell.detailTextLabel?.text = "\(reference.1) \(reference.2)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constant.customLengthCell, forIndexPath: indexPath)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCellRow = indexPath.row
        performSegueWithIdentifier(Constant.unwindFromPredefinedReference, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let editPhotoViewController = segue.destinationViewController as? EditPhotoVC {
            if segue.identifier == Constant.unwindFromPredefinedReference {
                editPhotoViewController.measuringReference = measuringReferences[selectedCellRow]
            } else if segue.identifier == Constant.unwindFromCustomReference {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? CustomLengthTableViewCell {
                    if cell.customLengthInput.text != nil && cell.customUnitInput.text != nil {
                        let customLength = Float(cell.customLengthInput.text!) ?? 0
                        editPhotoViewController.measuringReference = ("Custom", customLength, cell.customUnitInput.text!)
                    } else {
                        editPhotoViewController.measuringReference = nil
                    }
                }
            }
        }
    }
    
    
}
