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
    let thumbnail: UIImage?
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let date: NSDate
    let photoReferenceKey: String?
    
    init(data: NSDictionary) {
        name = data["name"] as! String
        photoDescription = data["description"] as? String
        latitude = data["latitude"] as! CLLocationDegrees
        longitude = data["longitude"] as! CLLocationDegrees
        photoReferenceKey = data["photoReferenceKey"] as? String
        
        if let imageString = data["thumbnailBase64"] as? String {
            let decodedData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            thumbnail = UIImage(data: decodedData!)
        } else {
            thumbnail = nil
        }
        
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
