//
//  PhotoMapViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/8/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit
import MapKit


class PhotoMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var photos = [MKPhoto]()
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.showsUserLocation = true
        }
    }
    

    @IBAction func setMapType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadDataFromFireBase()
        SharingManager.sharedInstance.addMomentsUpdatedHandler {self.renderAnnotations()}
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.distanceFilter = Constants.minimumDistanceToUpdate
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.renderAnnotations()
    }
    
    // MARK: - photo points
    
    fileprivate func clearPhotoPoints() {
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations as [MKAnnotation])
        }
    }
    
    fileprivate func handlePhotoPoints() {
        mapView.addAnnotations(photos)
        mapView.showAnnotations(photos, animated: true)
    }
    
    
    fileprivate func renderAnnotations() {
        photos = [MKPhoto]()
        for moment in SharingManager.sharedInstance.moments {
            if moment.username != nil && moment.pub_time_interval != nil && moment.latitude != nil && moment.longitude != nil && moment.id != nil {
                photos.append(MKPhoto(moment: moment))
            }
        }
        clearPhotoPoints()
        handlePhotoPoints()
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: mapView.userLocation.classForCoder) {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
            
        } else {
            view!.annotation = annotation
        }

        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = nil
        
        if let photoPoint = annotation as? MKPhoto {
            if let thumbnail = photoPoint.thumbnail {
                view!.leftCalloutAccessoryView = UIImageView(frame: Constants.LeftCalloutFrame)
                (view!.leftCalloutAccessoryView as! UIImageView).image = thumbnail
                view!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIButton
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: Constants.ShowImageDetailsSegue, sender: view)
    }
    
    // MARK - LocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.centerCoordinate = locations[locations.count - 1].coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Helpers.showLocationFailAlert(self)
    }    
    
    // MARK - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.ShowImageDetailsSegue {
            if let mapImageDetailsVC = segue.destination as? MapImageDetailsViewController {
                if let photoPoint = (sender as? MKAnnotationView)?.annotation as? MKPhoto {
                    mapImageDetailsVC.momentID = photoPoint.momentID
                }
            }
        }
    }
    
    // MARK: - Constants
    
    fileprivate struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "photopoint"
        static let ShowImageDetailsSegue = "ShowImageDetails"
        static let defaultRegionDistance: CLLocationDistance = 200000
        static let minimumDistanceToUpdate: CLLocationDistance = 40
    }
}
