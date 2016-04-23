//
//  MapImageDetailsViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/9/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class MapImageDetailsViewController: UIViewController {
    
    var name: String?
    var time: String?
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    var photoDescription: String?
    var photoUrl: String?
    
    override func viewDidLoad() {
        if photoUrl != nil {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            DataBase.photoFirebaseRef.childByAppendingPath(photoUrl).observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                if let base64EncodedString = snapshot.value as? String {
                    let decodedData = NSData(base64EncodedString: base64EncodedString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                    self.image = UIImage(data: decodedData!)
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            if image != nil {
                imageView.image = image
            }
        }
    }
    
    @IBOutlet weak var nameLable: UILabel! {
        didSet {
            if name != nil {
                nameLable.text = name
            }
        }
    }
    
    @IBOutlet weak var timeLable: UILabel! {
        didSet {
            if time != nil {
                timeLable.text = time
            }
        }
    }
    
    @IBOutlet weak var descriptionTextView: UITextView! {
        didSet {
            if photoDescription != nil {
                descriptionTextView.text = photoDescription
            }
        }
    }
}
