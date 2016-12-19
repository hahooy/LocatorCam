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
        static let timeFont = UIFont.boldSystemFont(ofSize: 15)
        static let descriptionFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    }
    
    @IBAction func addPhoto(_ sender: UIBarButtonItem) {
        let cameraActions = UIAlertController(title: "Upload Photo", message: "Choose the method", preferredStyle: .actionSheet)
        cameraActions.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(alert:UIAlertAction!) in self.useCamera(sender)}))
        cameraActions.addAction(UIAlertAction(title: "Album", style: .default, handler: {(alert:UIAlertAction!) in self.useCameraRoll(sender)}))
        cameraActions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        cameraActions.popoverPresentationController?.sourceView = view
        cameraActions.popoverPresentationController?.barButtonItem = sender
        present(cameraActions, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // add a handler to the sharedInstance, so that the tableView is refresh whenever
        // the moments data are updated
        SharingManager.sharedInstance.addMomentsUpdatedHandler { self.tableView.reloadData() }
        self.refreshControl?.addTarget(self, action: #selector(ListTableViewController.fetchNewMoments), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = UserInfo.currentChannel != nil ? "\(UserInfo.currentChannel!.name!)" : "Public"
        fetchNewMoments() // automatically fetch new moments when user gets to this view
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isToolbarHidden = false
    }
    
    @objc fileprivate func fetchNewMoments() {
        if SharingManager.sharedInstance.moments.count > 0 {
            SharingManager.sharedInstance.fetchMoments(publishedEarlier: false, publishedLater: true, spinner: nil, refreshControl: refreshControl)
        } else {
            SharingManager.sharedInstance.fetchMoments(publishedEarlier: false, publishedLater: false, spinner: scrollToBottomSpinner, refreshControl: refreshControl)
        }
    }
    
    // MARK: - control camera
    // use camera
    @IBAction func useCamera(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            isFromCamera = true
            
            self.present(imagePicker, animated: true,
                                       completion: nil)
        }
    }
    
    // open camera roll
    @IBAction func useCameraRoll(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.savedPhotosAlbum) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            isFromCamera = false
            
            self.present(imagePicker, animated: true,
                                       completion: nil)
        }
    }
    
    // MARK: - Image picker controler delegate functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismiss(animated: true, completion: nil)
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            photo = info[UIImagePickerControllerOriginalImage]
                as? UIImage
            performSegue(withIdentifier: "toEditPhoto", sender: self)
        } else if mediaType.isEqual(to: kUTTypeMovie as String) {
            // Code to support video here
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "toEditPhoto":
                if photo == nil {
                    return
                }
                
                // send image to edit photo view
                if let editVC = segue.destination as? EditPhotoVC {
                    editVC.photo = photo
                    editVC.isFromCamera = isFromCamera
                    editVC.hidesBottomBarWhenPushed = true
                }
            case "toPhotoDetails":
                if let mapImageDetailsVC = segue.destination as? MapImageDetailsViewController {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharingManager.sharedInstance.moments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.profileCellIdentifier, for: indexPath) as! ProfileTableViewCell
        
        configureCell(cell, indexPath: indexPath)
        tableViewStyle(cell)
        //cell.accessoryType = .DetailButton
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .DetailButton
        performSegue(withIdentifier: "toPhotoDetails", sender: SharingManager.sharedInstance.moments[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "toPhotoDetails", sender: SharingManager.sharedInstance.moments[indexPath.row])
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let moment = SharingManager.sharedInstance.moments[indexPath.row]
        var imageHeight: CGFloat = 0
        var nameLableHeight: CGFloat = 0
        var descriptionLableHeight: CGFloat = 0
        let lable = UILabel()
        
        if let name = moment.username {
            lable.text = name
            lable.font = Constant.nameFont
            let lableSize = lable.sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            nameLableHeight = lableSize.height
        }
        if let description = moment.description {
            lable.numberOfLines = 0
            lable.text = description
            lable.font = Constant.descriptionFont
            lable.lineBreakMode = .byTruncatingTail
            lable.textAlignment = .justified
            let lableSize = lable.sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            descriptionLableHeight = lableSize.height
        }
        
        if let base64String = moment.thumbnail_base64 {
            let decodedData = Data(base64Encoded: base64String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let decodedImage = UIImage(data: decodedData!)
            let aspectRatio = decodedImage!.size.height / decodedImage!.size.width
            imageHeight = UIScreen.main.bounds.width * aspectRatio
        }
        return nameLableHeight + imageHeight + descriptionLableHeight + 20
    }
    
    
    @IBOutlet weak var scrollToBottomSpinner: UIActivityIndicatorView!
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // the y difference between the origin of the content and the bottom of the scrollView
        let buttomOffset = scrollView.contentOffset.y + scrollView.frame.size.height
        let maximumOffset = scrollView.contentSize.height
        // load more data when scroll to the buttom
        if scrollToBottomSpinner.isAnimating == false && maximumOffset - buttomOffset < 30 && SharingManager.sharedInstance.moments.count > 0 {
            /* Fetch data that is earlier than the timestamp of the last moment */
            SharingManager.sharedInstance.fetchMoments(publishedEarlier: true, publishedLater: false, spinner: scrollToBottomSpinner, refreshControl: nil)
        }
    }
    
    
    // MARK:- Configure Cell
    
    func configureCell(_ cell: ProfileTableViewCell, indexPath: IndexPath) {
        let moment = SharingManager.sharedInstance.moments[indexPath.row]
        
        cell.nameLabel?.text = moment.username
        cell.descriptionLable?.text = moment.description
        
        let timeInterval = moment.pub_time_interval
        populateTimeInterval(cell, timeInterval: timeInterval)
        
        let base64String = moment.thumbnail_base64
        populateImage(cell, imageString: base64String)
    }
    
    // MARK:- Populate Timeinterval
    
    func populateTimeInterval(_ cell: ProfileTableViewCell, timeInterval: TimeInterval?) {
        if timeInterval == nil {
            return
        }
        let date = Date(timeIntervalSince1970: timeInterval!)
        let formatter = DateFormatter()
        if Date().timeIntervalSince(date) < 24 * 60 * 60 {
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .short
        }
        cell.timeLabel?.text = formatter.string(from: date)
    }
    
    // MARK:- Populate Image
    
    func populateImage(_ cell:ProfileTableViewCell, imageString: String?) {
        if imageString != nil {
            let decodedData = Data(base64Encoded: imageString!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            
            let decodedImage = UIImage(data: decodedData!)
            cell.profileImageView?.image = decodedImage
        }
    }
    
    // MARK:- Apply TableViewCell Style
    
    func tableViewStyle(_ cell: ProfileTableViewCell) {
        cell.contentView.backgroundColor = backgroundColor
        cell.backgroundColor = backgroundColor
        let backgroundView = UIView(frame: cell.frame)
        backgroundView.backgroundColor = backgroundColor
        cell.selectedBackgroundView = backgroundView
        
        cell.nameLabel?.font =  Constant.nameFont
        cell.nameLabel?.textColor = textColor
        cell.nameLabel?.backgroundColor = backgroundColor
        
        cell.timeLabel?.font = Constant.timeFont
        cell.timeLabel?.textColor = UIColor.gray
        cell.timeLabel?.backgroundColor = backgroundColor
        
        cell.descriptionLable?.font = Constant.descriptionFont
    }
    
}
