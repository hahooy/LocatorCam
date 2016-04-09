//
//  PhotoMapViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/8/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit
import MapKit
import Firebase


class PhotoMapViewController: UIViewController, MKMapViewDelegate {
    let firebase = Firebase(url:"https://fishboard.firebaseio.com/profiles")
    var photos = [MKPhoto]()
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromFireBase()
    }

    
    // MARK: - photo points

    private func clearPhotoPoints() {
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations as [MKAnnotation])
        }
    }
    
    private func handlePhotoPoints() {
        mapView.addAnnotations(photos)
        mapView.showAnnotations(photos, animated: true)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
                
        } else {
            view!.annotation = annotation
        }
        print("!")
        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = nil
        
        if let photoPoint = annotation as? MKPhoto {
            if let imageString = photoPoint.photoBase64 {
                print("!")
                let decodedData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                let decodedImage = UIImage(data: decodedData!)
                view!.leftCalloutAccessoryView = UIImageView(frame: Constants.LeftCalloutFrame)
                (view!.leftCalloutAccessoryView as! UIImageView).image = decodedImage
                view!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
            }
        }
        
        return view
    }
   
   
    // MARK: - load firebase data
    
    private func loadDataFromFireBase() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        firebase.observeEventType(.Value, withBlock: { snapshot in
            
            // clean up old points
            self.photos = [MKPhoto]()
            self.clearPhotoPoints()

            // show new points
            for item in snapshot.children {
                let dict = (item as! FDataSnapshot).value as! NSDictionary
                if dict["name"] != nil && dict["time"] != nil && dict["latitude"] != nil && dict["longitude"] != nil {
                    self.photos.append(MKPhoto(data: dict))
                }
            }
            
            // reload the photo data point to map view
            self.handlePhotoPoints()
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "photopoint"
        static let ShowImageSegue = "Show Image"
    }
}
