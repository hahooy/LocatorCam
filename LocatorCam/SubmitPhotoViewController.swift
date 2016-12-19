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
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        descriptionInput.resignFirstResponder()
    }
    
    // upload the photo
    @IBAction func uploadPhoto(_ sender: UIBarButtonItem) {
        
        // quit if no photo available for upload
        guard let image = imageView.image, let username = UserInfo.username else {
            return
        }
        
        // compress and encode the image
        
        let thumbnail = UIImageJPEGRepresentation(image.getThumbnail(SharingManager.Constant.maxThumbnailSize), 0)!
        let originalPhoto = UIImageJPEGRepresentation(image, 0)!
        // need to form url encoded the query string!!! otherwise + will be interpreted as space
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy()
        (s as AnyObject).removeCharacters(in: "+&")
        let thumbnailBase64String: NSString = thumbnail.base64EncodedString(options: .lineLength64Characters).addingPercentEncoding(withAllowedCharacters: s as! CharacterSet)! as NSString
        let originalPhotoBase64String: NSString = originalPhoto.base64EncodedString(options: .lineLength64Characters).addingPercentEncoding(withAllowedCharacters: s as! CharacterSet)! as NSString
        print(thumbnailBase64String.length)
        print(originalPhotoBase64String.length)
        // create a photo object
        var moment = [
            "username": username,
            "content_type": "JSON",
            "description": descriptionInput.text,
            "pub_time_interval": Date().timeIntervalSince1970,
            "thumbnail_base64": thumbnailBase64String,
            "photo_base64": originalPhotoBase64String
        ] as [String : Any]
        
        if let lat = photoLocation?.coordinate.latitude, let lon = photoLocation?.coordinate.longitude {
            moment["latitude"] = lat
            moment["longitude"] = lon
        }
        
        if let channelID = UserInfo.currentChannel?.id {
            moment["channel_id"] = channelID
        }

        // make API request to upload the photo
        let url:URL = URL(string: SharingManager.Constant.uploadMomentURL)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        for (key, value) in moment {
            paramString += "\(key)=\(value)&"
        }
 
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                if let message = json["message"] as? String {
                    print(message)
                    DispatchQueue.main.async(execute: {

                    })
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        task.resume()

        
        // return to the last page
        // let viewControlers = navigationController?.viewControllers
        // navigationController?.popToViewController(viewControlers![0], animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    // share image via sms, email and social media
    @IBAction func shareImage(_ sender: AnyObject) {
        if let image = imageView.image {
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(vc, animated: true, completion: nil)
        }
    }

}

extension UIImage {
    func getThumbnail(_ maxThumbnailSize: CGFloat) -> UIImage {
        let reduceRatio = min(maxThumbnailSize / self.size.height, maxThumbnailSize / self.size.width, 1.0)
        let thumbnailWidth = self.size.width * reduceRatio
        let thumbnailHeight = self.size.height * reduceRatio
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: thumbnailWidth, height: thumbnailHeight))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 1)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
