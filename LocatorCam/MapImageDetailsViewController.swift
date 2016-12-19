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
    @IBAction func goBackTapGestureHandler(_ sender: UITapGestureRecognizer) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        scrollView.setZoomScale(1.0, animated: true)        
    }
    
    var image: UIImage? {
        didSet {
            let imageWidth = UIScreen.main.bounds.width
            let imageHeight = imageWidth * image!.size.height / image!.size.width
            imageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
            imageView.contentMode = .scaleAspectFit
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
        goBackTapGesture.require(toFail: zoomOutTapGesture)
        activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // make API request to fetch the photo
        let url:URL = URL(string: SharingManager.Constant.fetchPhotoURL)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let paramString = "content_type=JSON&moment_id=\(id)"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                if let photoBase64String = json["photo_base64"] as? String {
                    let decodedData = Data(base64Encoded: photoBase64String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                    DispatchQueue.main.async(execute: {
                        self.image = UIImage(data: decodedData!)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.activityIndicator.stopAnimating()
                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isToolbarHidden = true
    }
    
    // MARK: - ScrollView Delegate Method
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
