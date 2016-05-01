//
//  EditPhotoVC.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 3/24/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase
import CoreLocation


/* control the main UI view */
class EditPhotoVC: UIViewController {
    
    
    var manager: OneShotLocationManager?    /* keep an instance of the location manager */
    var newMedia: Bool?
    var lineView: LineView?
    var photo: UIImage?
    var isFromCamera = false
    var photoLocation: CLLocation?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLineView(imageView)
        imageView.image = photo
        embedGPSData()
        self.navigationController?.setToolbarHidden(false, animated: true)
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
        var combinedImage: UIImage?
        
        if lineView != nil && lineView!.numberOfLines() > 0 {
            // flatten all views on the image to embed lines
            let views:[UIView] = [imageView]
            combinedImage = flattenViews(views)
        } else {
            combinedImage = imageView.image
        }
        
        UIImageWriteToSavedPhotosAlbum(combinedImage!, self,
                                       #selector(EditPhotoVC.image(_:didFinishSavingWithError:contextInfo:)), nil)
        let saveSuccessAlert = UIAlertController(title: "Success", message: "Photo has been saved to your local storage", preferredStyle: UIAlertControllerStyle.Alert)
        saveSuccessAlert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        presentViewController(saveSuccessAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func resetLines(sender: UIBarButtonItem) {
        removeAllLines()
    }
    
    private func embedGPSData() {
        manager = OneShotLocationManager() // request the current location
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                self.photoLocation = loc
                let locString = "\(formatDate(loc.timestamp))\n\(self.transformCoordinate(loc.coordinate)) +/- \(loc.horizontalAccuracy)m"

                // embeded text to image on the main queue
                dispatch_async(dispatch_get_main_queue()) {
                    if let img = self.imageView.image {
                        self.imageView.image = EditPhotoVC.textToImage(locString, inImage: img, atPoint: CGPointZero)
                    }
                }
            } else if let err = error {
                print(err.localizedDescription)
                // ask user to turn on GPS
                dispatch_async(dispatch_get_main_queue()) {
                    Helpers.showLocationFailAlert(self)
                }
            }
            
            // destroy the object immediately to save memory
            self.manager = nil
        }
    }
    
    // send image to the next view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var combinedImage: UIImage?
        
        if lineView != nil && lineView!.numberOfLines() > 0 {
            // flatten all views on the image to embed lines
            let views:[UIView] = [imageView]
            combinedImage = flattenViews(views)
        } else {
            combinedImage = imageView.image
        }
        
        // send image to the submit view controler
        let submitVC = (segue.destinationViewController as! SubmitPhotoViewController)
        submitVC.imageToSubmit = combinedImage
        // send location data to the submit view controler
        submitVC.photoLocation = photoLocation
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
    
    // embed text in UIImage
    static func textToImage(text: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage {
        
        // configure the font
        let textColor = UIColor.whiteColor()
        let textFont = UIFont(name: "Helvetica Neue", size: inImage.size.width * 0.04)!
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor
        ]
        let drawText = NSAttributedString(string: text as String, attributes: textFontAttributes)
        let textWidth = inImage.size.width
        let textHeight =  drawText.size().height
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(CGSize(width: inImage.size.width, height: inImage.size.height + textHeight))
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, textHeight, inImage.size.width, inImage.size.height))
        
        // Creating a text container within the image that is as wide as the image, as height as the text.

        let rect = CGRectMake(atPoint.x, atPoint.y, textWidth,  textHeight)
        
        // draw the background color for the text.
        UIColor(red: 0.1, green: 0.5, blue: 0.5, alpha: 1).set()
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
        lineView = LineView(frame: UIScreen.mainScreen().bounds)
        lineView!.backgroundColor = UIColor(white: 1, alpha: 0)
        lineView!.addGestureRecognizer(UIPanGestureRecognizer(target: lineView, action: #selector(LineView.move)))
        lineView!.contentMode = UIViewContentMode.ScaleAspectFit
        parentView.addSubview(lineView!)
    }
    
    // remove all lines
    private func removeAllLines() {
        if let lines = lineView {
            lines.removeAllLines()
        }
    }
    
    // Flattens <allViews> into single UIImage
    private func flattenViews(allViews: [UIView]) -> UIImage? {
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
        
        // resize the snapshot to the size of the original image
        // let ratio:CGFloat = imageView.image!.size.width / imageView.frame.width
        
        let x:CGFloat = imageView.frame.origin.x * UIScreen.mainScreen().scale
        let y:CGFloat = imageView.frame.origin.y * UIScreen.mainScreen().scale
        let width = imageView.frame.width * UIScreen.mainScreen().scale
        let height = imageView.frame.height * UIScreen.mainScreen().scale
        // let height = imageView.image!.size.height / ratio * UIScreen.mainScreen().scale
        
        let imageRef = image.CGImage!
        let imageArea = CGRectMake(x, y, width, height)
        let subImageRef: CGImageRef = CGImageCreateWithImageInRect(imageRef, imageArea)!
        print("x:\(x) y:\(y) width:\(width) height:\(height)")
        // Return image
        return UIImage(CGImage: subImageRef)
    }
    
    // convert coordinate from degree to degree, minute and second
    private func transformCoordinate(coordinate: CLLocationCoordinate2D) -> String {
        // convert the degree to coresponding degree + minute + second
        let latitudeInSeconds = abs(Int(coordinate.latitude * 3600))
        let latitudeDegrees = latitudeInSeconds / 3600
        let latitudeMinutes = (latitudeInSeconds - latitudeDegrees * 3600) / 60
        let latitudeSeconds = latitudeInSeconds - latitudeDegrees * 3600 - latitudeMinutes * 60
        let longitudeInSeconds = abs(Int(coordinate.longitude * 3600))
        let longitudeDegrees = longitudeInSeconds / 3600
        let longitudeMinutes = (longitudeInSeconds - longitudeDegrees * 3600) / 60
        let longitudeSeconds = longitudeInSeconds - longitudeDegrees * 3600 - longitudeMinutes * 60
        
        return "\(coordinate.latitude >= 0 ? "N" : "S") \(latitudeDegrees)° \(latitudeMinutes)' \(latitudeSeconds)\", \(coordinate.longitude >= 0 ? "E" : "W") \(longitudeDegrees)° \(longitudeMinutes)' \(longitudeSeconds)\""
    }
}