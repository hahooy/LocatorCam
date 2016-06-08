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
    
    struct Constant {
        static let profileCellIdentifier = "profileCell"
        static let nameFont = UIFont(name: "HelveticaNeue-Medium", size: 15)
        static let timeFont = UIFont.boldSystemFontOfSize(15)
        static let descriptionFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
    
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
        self.refreshControl?.addTarget(self, action: #selector(ListTableViewController.fetchNewMoments), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbarHidden = true
        self.navigationController?.navigationBarHidden = false
        fetchNewMoments() // automatically fetch new moments when user gets to this view
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.toolbarHidden = false
    }
    
    @objc private func fetchNewMoments() {
        print("fetching moments")
        if SharingManager.sharedInstance.moments.count > 0 {
            let startTime = SharingManager.sharedInstance.moments[0].pub_time_interval
            SharingManager.sharedInstance.fetchMoments(startTime: startTime, endTime: nil, spinner: nil, refreshControl: refreshControl)
        }
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
                    if let cellData = sender as? Moment {
                        mapImageDetailsVC.momentID = cellData.id
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.profileCellIdentifier, forIndexPath: indexPath) as! ProfileTableViewCell
        
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
    
    /*
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let dict = SharingManager.sharedInstance.moments.removeAtIndex(indexPath.row)
            let key = dict["key"] as! String
            
            // delete data from firebase
            let profile = DataBase.momentFirebaseRef.ref.childByAppendingPath(key)
            profile.removeValue()
        }
    }
 */
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let moment = SharingManager.sharedInstance.moments[indexPath.row]
        var imageHeight: CGFloat = 0
        var nameLableHeight: CGFloat = 0
        var descriptionLableHeight: CGFloat = 0
        let lable = UILabel()
        
        if let name = moment.username {
            lable.text = name
            lable.font = Constant.nameFont
            let lableSize = lable.sizeThatFits(CGSize(width: UIScreen.mainScreen().bounds.width, height: CGFloat.max))
            nameLableHeight = lableSize.height
        }
        if let description = moment.description {
            lable.numberOfLines = 0
            lable.text = description
            lable.font = Constant.descriptionFont
            lable.lineBreakMode = .ByTruncatingTail
            lable.textAlignment = .Justified
            let lableSize = lable.sizeThatFits(CGSize(width: UIScreen.mainScreen().bounds.width, height: CGFloat.max))
            descriptionLableHeight = lableSize.height
        }
        
        if let base64String = moment.thumbnail_base64 {
            let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            let decodedImage = UIImage(data: decodedData!)
            let aspectRatio = decodedImage!.size.height / decodedImage!.size.width
            imageHeight = UIScreen.mainScreen().bounds.width * aspectRatio
        }
        return nameLableHeight + imageHeight + descriptionLableHeight + 20
    }
    
    
    @IBOutlet weak var scrollToBottomSpinner: UIActivityIndicatorView!
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // the y difference between the origin of the content and the bottom of the scrollView
        let buttomOffset = scrollView.contentOffset.y + scrollView.frame.size.height
        let maximumOffset = scrollView.contentSize.height
        // load more data when scroll to the buttom
        if scrollToBottomSpinner.isAnimating() == false && maximumOffset - buttomOffset < 30 && SharingManager.sharedInstance.moments.count > 0 {
            /* Fetch data that is earlier than the timestamp of the last moment */
            if let endingTime = SharingManager.sharedInstance.moments[SharingManager.sharedInstance.moments.count - 1].pub_time_interval {
                SharingManager.sharedInstance.fetchMoments(startTime: nil, endTime: endingTime, spinner: scrollToBottomSpinner, refreshControl: nil)
            }
        }
    }
    
    
    // MARK:- Configure Cell
    
    func configureCell(cell: ProfileTableViewCell, indexPath: NSIndexPath) {
        let moment = SharingManager.sharedInstance.moments[indexPath.row]
        
        cell.nameLabel?.text = moment.username
        cell.descriptionLable?.text = moment.description
        
        let timeInterval = moment.pub_time_interval
        populateTimeInterval(cell, timeInterval: timeInterval)
        
        let base64String = moment.thumbnail_base64
        populateImage(cell, imageString: base64String)
    }
    
    // MARK:- Populate Timeinterval
    
    func populateTimeInterval(cell: ProfileTableViewCell, timeInterval: NSTimeInterval?) {
        if timeInterval == nil {
            return
        }
        let date = NSDate(timeIntervalSince1970: timeInterval!)
        let formatter = NSDateFormatter()
        if NSDate().timeIntervalSinceDate(date) < 24 * 60 * 60 {
            formatter.timeStyle = .ShortStyle
        } else {
            formatter.dateStyle = .ShortStyle
        }
        cell.timeLabel?.text = formatter.stringFromDate(date)
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
        
        cell.nameLabel?.font =  Constant.nameFont
        cell.nameLabel?.textColor = textColor
        cell.nameLabel?.backgroundColor = backgroundColor
        
        cell.timeLabel?.font = Constant.timeFont
        cell.timeLabel?.textColor = UIColor.grayColor()
        cell.timeLabel?.backgroundColor = backgroundColor
        
        cell.descriptionLable?.font = Constant.descriptionFont
    }

}