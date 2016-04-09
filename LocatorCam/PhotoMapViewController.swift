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
            mapView.showsUserLocation = true
            

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromFireBase()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBarHidden = false
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
        if annotation.isKindOfClass(mapView.userLocation.classForCoder) {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
            
        } else {
            view!.annotation = annotation
        }

        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = nil
        
        if let photoPoint = annotation as? MKPhoto {
            if let photo = photoPoint.photo {
                view!.leftCalloutAccessoryView = UIImageView(frame: Constants.LeftCalloutFrame)
                (view!.leftCalloutAccessoryView as! UIImageView).image = photo
                view!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
            }
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier(Constants.ShowImageDetailsSegue, sender: view)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if userLocation.location != nil {
            mapView.centerCoordinate = userLocation.location!.coordinate
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.ShowImageDetailsSegue {
            if let mapImageDetailsVC = segue.destinationViewController as? MapImageDetailsViewController {
                if let photoPoint = (sender as? MKAnnotationView)?.annotation as? MKPhoto {
                    mapImageDetailsVC.image = photoPoint.photo
                    mapImageDetailsVC.name = photoPoint.name
                    mapImageDetailsVC.time = photoPoint.subtitle
                    mapImageDetailsVC.photoDescription = photoPoint.photoDescription
                }
            }
        }
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
        static let ShowImageDetailsSegue = "ShowImageDetails"
        static let defaultRegionDistance: CLLocationDistance = 200000
    }
}