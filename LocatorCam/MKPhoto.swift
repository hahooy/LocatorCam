//  This class provides data of user upload photo for map annotation
//
//  MKPhoto.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/8/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import MapKit
import UIKit
import MobileCoreServices

class MKPhoto: NSObject, MKAnnotation {
    
    let name: String
    let photoDescription: String?
    let photoBase64: String?
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let date: NSDate
    
    init(data: NSDictionary) {
        name = data["name"] as! String
        photoDescription = data["description"] as? String
        latitude = data["latitude"] as! CLLocationDegrees
        longitude = data["longitude"] as! CLLocationDegrees
        photoBase64 = data["photoBase64"] as? String
        
        let timeInterval = data["time"] as! NSTimeInterval
        date = NSDate(timeIntervalSince1970: timeInterval)
    }
    
    
    // MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? { return name }
    
    var subtitle: String? { return formatDate(date) }
}
