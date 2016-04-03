//
//  EditPhotoVC.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 3/24/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit
import MobileCoreServices


/* control the main UI view */
class EditPhotoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /* keep an instance of the location manager while it fetches the location for you */
    var manager: OneShotLocationManager?
    var newMedia: Bool?
    var lineView: LineView?
    @IBOutlet weak var imageView: UIImageView!
    
    
    // use camera
    @IBAction func useCamera(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
            removeLines()
            
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
    
    // open camera roll
    @IBAction func useCameraRoll(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            removeLines()
            
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
    
    // add a line to line view
    @IBAction func addMeasurementLine(sender: UIBarButtonItem) {
        lineView?.addLine()        
    }
    
    // remove a line from line view
    @IBAction func removeMeasurementLine(sender: UIBarButtonItem) {
        lineView?.removeLine()
    }
    
    // save the image locally
    @IBAction func saveImage(sender: UIBarButtonItem) {
        if (imageView.image) != nil {
            let views:[UIView] = [imageView]
            let combinedImage = flattenViews(views)
            UIImageWriteToSavedPhotosAlbum(combinedImage!, self,
                                       #selector(EditPhotoVC.image(_:didFinishSavingWithError:contextInfo:)), nil)
            removeLines()
            imageView.image = combinedImage
        }
    }
    
    // share image via sms, email and social media
    @IBAction func shareImage(sender: AnyObject) {
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
                        image = EditPhotoVC.textToImage(loc.description, inImage: image, atPoint: CGPointZero)
                    } else if let err = error {
                        print(err.localizedDescription)
                    }
                    self.imageView.image = image
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
    
    // embed text in UIImage
    static func textToImage(text: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage {

        // configure the font
        let textColor = UIColor.whiteColor()
        let textFont = UIFont(name: "Helvetica Bold", size: 120)!
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor
        ]
        let drawText = NSAttributedString(string: text as String, attributes: textFontAttributes)
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))

        // Creating a text container within the image that is as wide as the image, as height as the text.
        let textWidth = inImage.size.width
        let textHeight = (ceil(drawText.size().width) / inImage.size.width * drawText.size().height) * 1.2
        let rect = CGRectMake(atPoint.x, atPoint.y, textWidth,  textHeight)

        // draw the background color for the text.
        UIColor(red: 0.1, green: 0.5, blue: 0.5, alpha: 0.8).set()
        UIBezierPath(rect: rect).fill()
        
        // Draw the text into the container.
        drawText.drawInRect(rect)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
    // add lineView to the parent view
    private func loadLineView(parentView: UIView) {
            let lineFrame = CGRectMake(parentView.bounds.origin.x, parentView.bounds.origin.y, parentView.bounds.size.width, parentView.bounds.size.height)
            lineView = LineView(frame: lineFrame)
            lineView!.backgroundColor = UIColor(white: 1, alpha: 0)
            lineView!.addGestureRecognizer(UIPanGestureRecognizer(target: lineView, action: Selector("move:")))
            lineView!.contentMode = UIViewContentMode.ScaleAspectFit
            parentView.addSubview(lineView!)
    }
    
    // remove all lines
    private func removeLines() {
        if let lines = lineView {
            lines.removeAllLines()
        }
    }
    
    // Flattens <allViews> into single UIImage
    func flattenViews(allViews: [UIView]) -> UIImage? {
        // Return nil if <allViews> empty
        if (allViews.isEmpty) {
            return nil
        }
        
        // If here, compose image out of views in <allViews>
        // Create graphics context
        UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        
        // Draw each view into context
        for curView in allViews {
            curView.drawViewHierarchyInRect(curView.frame, afterScreenUpdates: false)
        }
        
        // Extract image & end context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return image
        return image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLineView(imageView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}