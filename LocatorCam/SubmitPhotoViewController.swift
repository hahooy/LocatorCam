//
//  SubmitPhotoViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/4/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SubmitPhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionInput: UITextView!
    var imageToSubmit: UIImage?
    var photoLocation: CLLocation?
    var profileRef = Firebase(url: "https://fishboard.firebaseio.com/profiles")
    
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
        let data = UIImageJPEGRepresentation(imageView.image!, 0.05)!
        let base64String:NSString = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        // create a new child under profiles in Firebase
        let itemRef = profileRef.childByAutoId()
        
        // create a photo object
        let photo = [
            "key": itemRef.key,
            "name": "anonymous",
            "time": NSDate().timeIntervalSince1970,
            "description": descriptionInput.text,
            "photoBase64": base64String,
            "latitude": photoLocation?.coordinate.latitude ?? 0,
            "longitude": photoLocation?.coordinate.longitude ?? 0
        ]

        // write the photo to Firebase
        itemRef.setValue(photo)
        
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
