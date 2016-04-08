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
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLineView(imageView)
        imageView.image = photo
        embedGPSData()
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
        let views:[UIView] = [imageView]
        let combinedImage = flattenViews(views)
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
                let locString = "\(formatDate(loc.timestamp))\n\(self.transformCoordinate(loc.coordinate)) +/- \(loc.horizontalAccuracy)m"
                print(locString)
                // embeded text to image
                if let img = self.imageView.image {
                    self.imageView.image = EditPhotoVC.textToImage(locString, inImage: img, atPoint: CGPointZero)
                }
            } else if let err = error {
                print(err.localizedDescription)
            }

            // destroy the object immediately to save memory
            self.manager = nil
        }
    }
    
    // send image to the next view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if imageView.image == nil {
            return
        }
        // flatten all views on the image
        let views:[UIView] = [imageView]
        let combinedImage = flattenViews(views)
        
        // send it to the submit view controler
        let submitVC = (segue.destinationViewController as! SubmitPhotoViewController)
        submitVC.imageToSubmit = combinedImage
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
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a text container within the image that is as wide as the image, as height as the text.
        let textWidth = inImage.size.width
        let textHeight = (ceil(drawText.size().width) / inImage.size.width * drawText.size().height) * 1.6
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
        lineView = LineView(frame: UIScreen.mainScreen().bounds)
        lineView!.backgroundColor = UIColor(white: 1, alpha: 0)
        lineView!.addGestureRecognizer(UIPanGestureRecognizer(target: lineView, action: Selector("move:")))
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