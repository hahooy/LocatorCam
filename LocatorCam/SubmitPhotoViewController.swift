//
//  SubmitPhotoViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/4/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit
import CoreLocation

class SubmitPhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionInput: UITextView!
    var imageToSubmit: UIImage?
    var photoLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColorDarker
        imageView.image = imageToSubmit
    }
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        descriptionInput.resignFirstResponder()
    }
    
    // upload the photo
    @IBAction func uploadPhoto(sender: UIBarButtonItem) {
        
        // quit if no photo available for upload
        guard let image = imageView.image, let username = UserInfo.username else {
            return
        }
        
        // compress and encode the image
        let thumbnail = UIImageJPEGRepresentation(image.getThumbnail(), 1)!
        let thumbnailBase64String: NSString = thumbnail.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let originalPhoto = UIImageJPEGRepresentation(image, 0)!
        let originalPhotoBase64String: NSString = originalPhoto.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        
        // create a photo object
        let moment = [
            "username": username,
            "content_type": "JSON",
            "description": descriptionInput.text,
            "latitude": photoLocation?.coordinate.latitude ?? 0,
            "longitude": photoLocation?.coordinate.longitude ?? 0,
            "pub_time_interval": NSDate().timeIntervalSince1970,
            "thumbnail_base64": thumbnailBase64String,
            "photo_base64": originalPhotoBase64String
        ]
        
        // make API request to upload the photo
        let url:NSURL = NSURL(string: SharingManager.Constant.uploadMomentURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        var paramString = ""
        
        for (key, value) in moment {
            paramString += "\(key)=\(value)&"
        }
        
        print(paramString)
        
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                if let message = json["message"] as? String {
                    print(message)
                    dispatch_async(dispatch_get_main_queue(), {

                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        task.resume()

        
        // return to the first page
        let viewControlers = navigationController?.viewControllers
        navigationController?.popToViewController(viewControlers![0], animated: true)
    }
    
    // share image via sms, email and social media
    @IBAction func shareImage(sender: AnyObject) {
        if let image = imageView.image {
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            presentViewController(vc, animated: true, completion: nil)
        }
    }

}

extension UIImage {
    func getThumbnail() -> UIImage {
        let thumbnailWidth = SharingManager.Constant.thumbnailWidth
        let thumbnailHeight = self.size.height * thumbnailWidth / self.size.width
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: thumbnailWidth, height: thumbnailHeight))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 1)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
