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
    var momentID: Int?
    
    override func viewDidLoad() {
        guard let id = momentID else {
            return
        }
        goBackTapGesture.requireGestureRecognizerToFail(zoomOutTapGesture)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // make API request to fetch the photo
        let url:NSURL = NSURL(string: SharingManager.Constant.fetchPhotoURL)!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let paramString = "content_type=JSON&moment_id=\(id)"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                if let photoBase64String = json["photo_base64"] as? String {
                    let decodedData = NSData(base64EncodedString: photoBase64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                    self.image = UIImage(data: decodedData!)
                    print(photoBase64String.substringToIndex(photoBase64String.startIndex.advancedBy(20)))
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.activityIndicator.stopAnimating()
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()
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
