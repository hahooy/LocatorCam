//
//  MapImageDetailsViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/9/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class MapImageDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    var imageView = UIImageView()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = 3.0
            scrollView.minimumZoomScale = 1.0
        }
    }
    
    @IBOutlet var zoomOutTapGesture: UITapGestureRecognizer!
    @IBOutlet var goBackTapGesture: UITapGestureRecognizer!
    @IBAction func goBackTapGestureHandler(sender: UITapGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func tapGesture(sender: UITapGestureRecognizer) {
        scrollView.setZoomScale(1.0, animated: true)        
    }
    
    var image: UIImage? {
        didSet {
            let imageWidth = UIScreen.mainScreen().bounds.width
            let imageHeight = imageWidth * image!.size.height / image!.size.width
            imageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
            imageView.contentMode = .ScaleAspectFit
            imageView.image = image
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
            imageView.center = scrollView.center
        }
    }
    var photoDescription: String?
    var photoUrl: String?
    
    override func viewDidLoad() {
        //self.navigationController?.navigationBarHidden = true
        goBackTapGesture.requireGestureRecognizerToFail(zoomOutTapGesture)
        activityIndicator.startAnimating()
        if photoUrl != nil {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            DataBase.photoFirebaseRef.childByAppendingPath(photoUrl).observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                if let base64EncodedString = snapshot.value as? String {
                    let decodedData = NSData(base64EncodedString: base64EncodedString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                    self.image = UIImage(data: decodedData!)
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = true
    }
    
    // MARK: - ScrollView Delegate Method
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
