//
//  ViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 3/24/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit
import MobileCoreServices


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /* keep an instance of the location manager while it fetches the location for you */
    var manager: OneShotLocationManager?
    var newMedia: Bool?
    
    @IBOutlet weak var imageView: UIImageView!
    var lineView: LineView1?
    
    
    @IBAction func useCamera(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
            newMedia = true
        }
    }
    
    @IBAction func useCameraRoll(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
            newMedia = false
        }
    }
    

    @IBAction func addMeasurementLine(sender: UIBarButtonItem) {
        lineView?.addLine()        
    }
    
    @IBAction func shareImage(sender: UILongPressGestureRecognizer) {
        if let image = imageView.image {
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as String) {
            var image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            imageView.image = image
            
            if (newMedia == true) {
                /* if this is a new image, fetch the location and embed it in the image, refresh the image view with the new image and save the image to album */
                manager = OneShotLocationManager() // request the current location
                manager!.fetchWithCompletion {location, error in
                    // fetch location or an error
                    if let loc = location {
                        // embeded text to image
                        image = ViewController.textToImage(loc.description, inImage: image, atPoint: CGPointMake(0, 0))
                    } else if let err = error {
                        print(err.localizedDescription)
                    }
                    self.imageView.image = image
                    // save the image
                    UIImageWriteToSavedPhotosAlbum(image, self,
                        #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    // destroy the object immediately to save memory
                    self.manager = nil
                }
            }
        } else if mediaType.isEqualToString(kUTTypeMovie as String) {
            // Code to support video here
        }
        
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                                          message: "Failed to save image",
                                          preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                                       completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    static func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage {
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 120)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add lineView to the imageView
        let lineFrame = CGRectMake(imageView.bounds.origin.x, imageView.bounds.origin.y, imageView.bounds.width, imageView.bounds.height)
        print("\(imageView.bounds.width) \(imageView.bounds.height)")
        lineView = LineView1(frame: lineFrame)
        lineView!.backgroundColor = UIColor(white: 0, alpha: 0.5)
        lineView!.addGestureRecognizer(UIPanGestureRecognizer(target: lineView, action: Selector("move:")))
        lineView!.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.addSubview(lineView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}