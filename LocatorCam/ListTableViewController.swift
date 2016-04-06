//
//  ListTableViewController.swift
//  FirebaseDemo
//
//  Created by Ravi Shankar on 22/11/15.
//  Copyright © 2015 Ravi Shankar. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices


class ListTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let firebase = Firebase(url:"https://fishboard.firebaseio.com/profiles")
    var items = [NSDictionary]()
    var photo: UIImage?
    
    
    @IBAction func addPhoto(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Upload Photo", message: "Choose the method", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {(alert:UIAlertAction!) in self.useCamera(sender)}))
        alertController.addAction(UIAlertAction(title: "Album", style: UIAlertActionStyle.Default, handler: {(alert:UIAlertAction!) in self.useCameraRoll(sender)}))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(alert:UIAlertAction!) in print("Cancel")}))
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.barButtonItem = sender
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 500
        self.tableView.allowsSelection = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        items = [NSDictionary]()
        
        loadDataFromFirebase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                as! UIImage
            performSegueWithIdentifier("toEditPhoto", sender: self)
            
            
        } else if mediaType.isEqualToString(kUTTypeMovie as String) {
            // Code to support video here
        }
        
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                                          message: "Failed to save image",
                                          preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                                       completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // send image to edit photo view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if photo == nil {
            return
        }

        // send it to the submit view controler
        let submitVC = (segue.destinationViewController as! EditPhotoVC)
        submitVC.photo = photo
    }
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! ProfileTableViewCell
        
        configureCell(cell, indexPath: indexPath)
        tableViewStyle(cell)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let dict = items[indexPath.row]
            let key = dict["key"] as! String
            
            // delete data from firebase
            
            let profile = firebase.ref.childByAppendingPath(key)
            profile.removeValue()
        }
    }
    
    // MARK:- Configure Cell
    
    func configureCell(cell: ProfileTableViewCell, indexPath: NSIndexPath) {
        let dict = items[indexPath.row]
        
        cell.nameLabel?.text = dict["name"] as? String
        cell.descriptionLable?.text = dict["description"] as? String
        
        let timeInterval = dict["time"] as! NSTimeInterval
        populateTimeInterval(cell, timeInterval: timeInterval)
        
        let base64String = dict["photoBase64"] as! String
        populateImage(cell, imageString: base64String)
        
    }
    
    // MARK:- Populate Timeinterval
    
    func populateTimeInterval(cell: ProfileTableViewCell, timeInterval: NSTimeInterval) {
        
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, HH:mm"
        cell.timeLabel?.text = dateFormatter.stringFromDate(date)
    }
    
    // MARK:- Populate Image
    
    func populateImage(cell:ProfileTableViewCell, imageString: String) {
        
        let decodedData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedImage = UIImage(data: decodedData!)
        
        cell.profileImageView?.image = decodedImage
        
    }
    
    // MARK:- Apply TableViewCell Style
    
    func tableViewStyle(cell: ProfileTableViewCell) {
        cell.contentView.backgroundColor = backgroundColor
        cell.backgroundColor = backgroundColor
        
        cell.nameLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 15)
        cell.nameLabel?.textColor = textColor
        cell.nameLabel?.backgroundColor = backgroundColor
        
        cell.timeLabel?.font = UIFont.boldSystemFontOfSize(15)
        cell.timeLabel?.textColor = UIColor.grayColor()
        cell.timeLabel?.backgroundColor = backgroundColor
    }
    
    // MARK:- Load data from Firebase
    
    func loadDataFromFirebase() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        firebase.queryOrderedByChild("time").observeEventType(.Value, withBlock: { snapshot in
            var tempItems = [NSDictionary]()
            
            for item in snapshot.children {
                let child = item as! FDataSnapshot
                let dict = child.value as! NSDictionary
                tempItems.append(dict)
            }
            
            self.items = tempItems.reverse()
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
        })
    }
}