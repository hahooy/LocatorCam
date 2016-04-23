//
//  ListTableViewController.swift
//  FirebaseDemo
//
//  Created by Ravi Shankar on 22/11/15.
//  Copyright © 2015 Ravi Shankar. All rights reserved.
//

import UIKit
import MobileCoreServices



class ListTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photo: UIImage?
    var isFromCamera = false // indicating if this image is taken from the camera
    
    
    
    @IBAction func addPhoto(sender: UIBarButtonItem) {
        let cameraActions = UIAlertController(title: "Upload Photo", message: "Choose the method", preferredStyle: .ActionSheet)
        cameraActions.addAction(UIAlertAction(title: "Camera", style: .Default, handler: {(alert:UIAlertAction!) in self.useCamera(sender)}))
        cameraActions.addAction(UIAlertAction(title: "Album", style: .Default, handler: {(alert:UIAlertAction!) in self.useCameraRoll(sender)}))
        cameraActions.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        cameraActions.popoverPresentationController?.sourceView = view
        cameraActions.popoverPresentationController?.barButtonItem = sender
        presentViewController(cameraActions, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // add a handler to the sharedInstance, so that the tableView is refresh whenever
        // the moments data are updated
        SharingManager.sharedInstance.addMomentsUpdatedHandler { self.tableView.reloadData() }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // MARK: - control camera
    // use camera
    @IBAction func useCamera(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            isFromCamera = true
            
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
        }
    }
    
    // open camera roll
    @IBAction func useCameraRoll(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            isFromCamera = false
            
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
        }
    }
    
    // MARK: - Image picker controler delegate functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as String) {
            photo = info[UIImagePickerControllerOriginalImage]
                as? UIImage
            performSegueWithIdentifier("toEditPhoto", sender: self)
        } else if mediaType.isEqualToString(kUTTypeMovie as String) {
            // Code to support video here
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "toEditPhoto":
                if photo == nil {
                    return
                }
                
                // send image to edit photo view
                if let editVC = segue.destinationViewController as? EditPhotoVC {
                    editVC.photo = photo
                    editVC.isFromCamera = isFromCamera
                    editVC.hidesBottomBarWhenPushed = true
                }
            case "toPhotoDetails":
                if let mapImageDetailsVC = segue.destinationViewController as? MapImageDetailsViewController {
                    if let cellData = sender as? NSDictionary {
                        mapImageDetailsVC.name = cellData["name"] as? String
                        let date = NSDate(timeIntervalSince1970: cellData["time"] as! NSTimeInterval)
                        mapImageDetailsVC.time = formatDate(date)
                        mapImageDetailsVC.photoDescription = cellData["description"] as? String
                        mapImageDetailsVC.photoUrl = cellData["photoReferenceKey"] as? String
                    }
                }
                
            default:
                break
            }
        }
        
    }
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharingManager.sharedInstance.moments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! ProfileTableViewCell
        
        configureCell(cell, indexPath: indexPath)
        tableViewStyle(cell)
        //cell.accessoryType = .DetailButton
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .DetailButton
        performSegueWithIdentifier("toPhotoDetails", sender: SharingManager.sharedInstance.moments[indexPath.row])
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        //tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toPhotoDetails", sender: SharingManager.sharedInstance.moments[indexPath.row])
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let dict = SharingManager.sharedInstance.moments.removeAtIndex(indexPath.row)
            let key = dict["key"] as! String
            
            // delete data from firebase
            let profile = DataBase.momentFirebaseRef.ref.childByAppendingPath(key)
            profile.removeValue()
        }
    }
    
    
    @IBOutlet weak var scrollToBottomSpinner: UIActivityIndicatorView!
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // the y difference between the origin of the content and the bottom of the scrollView
        let buttomOffset = scrollView.contentOffset.y + scrollView.frame.size.height
        let maximumOffset = scrollView.contentSize.height
        // load more data when scroll to the buttom
        if scrollToBottomSpinner.isAnimating() == false && maximumOffset - buttomOffset < 30 && SharingManager.sharedInstance.moments.count > 0 {
            scrollToBottomSpinner.startAnimating()
            /* Fetch data that is earlier than the timestamp of the last moment */
            if let endingTime = SharingManager.sharedInstance.moments[SharingManager.sharedInstance.moments.count - 1]["time"] as? NSTimeInterval {
                SharingManager.sharedInstance.loadDataFromFirebase(endingTime - SharingManager.Constant.minimumTimeInterval, spinner: scrollToBottomSpinner)
            }
        }
    }
    
    
    // MARK:- Configure Cell
    
    func configureCell(cell: ProfileTableViewCell, indexPath: NSIndexPath) {
        let dict = SharingManager.sharedInstance.moments[indexPath.row]
        
        cell.nameLabel?.text = dict["name"] as? String
        cell.descriptionLable?.text = dict["description"] as? String
        
        let timeInterval = dict["time"] as? NSTimeInterval
        populateTimeInterval(cell, timeInterval: timeInterval)
        
        let base64String = dict["thumbnailBase64"] as? String
        populateImage(cell, imageString: base64String)
    }
    
    // MARK:- Populate Timeinterval
    
    func populateTimeInterval(cell: ProfileTableViewCell, timeInterval: NSTimeInterval?) {
        if timeInterval == nil {
            return
        }
        let date = NSDate(timeIntervalSince1970: timeInterval!)
        cell.timeLabel?.text = formatDate(date)
    }
    
    // MARK:- Populate Image
    
    func populateImage(cell:ProfileTableViewCell, imageString: String?) {
        if imageString != nil {
            let decodedData = NSData(base64EncodedString: imageString!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            
            let decodedImage = UIImage(data: decodedData!)
            
            cell.profileImageView?.image = decodedImage
        }
    }
    
    // MARK:- Apply TableViewCell Style
    
    func tableViewStyle(cell: ProfileTableViewCell) {
        cell.contentView.backgroundColor = backgroundColor
        cell.backgroundColor = backgroundColor
        let backgroundView = UIView(frame: cell.frame)
        backgroundView.backgroundColor = backgroundColor
        cell.selectedBackgroundView = backgroundView
        
        cell.nameLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 15)
        cell.nameLabel?.textColor = textColor
        cell.nameLabel?.backgroundColor = backgroundColor
        
        cell.timeLabel?.font = UIFont.boldSystemFontOfSize(15)
        cell.timeLabel?.textColor = UIColor.grayColor()
        cell.timeLabel?.backgroundColor = backgroundColor
    }
}