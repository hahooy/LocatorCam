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
    var image: UIImage?
    var photoDescription: String?

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
