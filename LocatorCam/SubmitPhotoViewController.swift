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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        descriptionInput.resignFirstResponder()
    }
    
    // upload the photo to firebase
    @IBAction func uploadPhoto(sender: UIBarButtonItem) {
        
        // quit if no photo available for upload
        if imageView.image == nil {
            return
        }
        
        // compress and encode the image
        let thumbnail = UIImageJPEGRepresentation(imageView.image!.resize(0.1), 1)!
        let thumbnailBase64String: NSString = thumbnail.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let originalPhoto = UIImageJPEGRepresentation(imageView.image!, 0)!
        let originalPhotoBase64String: NSString = originalPhoto.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        
        // create a new child under profiles in Firebase
        let momentRef = DataBase.momentFirebaseRef.childByAutoId()
        let photoRef = DataBase.photoFirebaseRef.childByAutoId()
        
        // create a photo object
        let moment = [
            "key": momentRef.key,
            "name": "anonymous",
            "time": NSDate().timeIntervalSince1970,
            "description": descriptionInput.text,
            "thumbnailBase64": thumbnailBase64String,
            "photoReferenceKey": photoRef.key,
            "latitude": photoLocation?.coordinate.latitude ?? 0,
            "longitude": photoLocation?.coordinate.longitude ?? 0
        ]

        // write data to Firebase
        SharingManager.sharedInstance.addMoment(momentRef, data: moment)
        SharingManager.sharedInstance.addPhoto(photoRef, base64String: originalPhotoBase64String)
        
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
    func resize(scale: CGFloat) -> UIImage {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.size.width * scale, height: self.size.height * scale))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 1)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
