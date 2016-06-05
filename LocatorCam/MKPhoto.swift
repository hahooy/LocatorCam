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
    let momentID: Int?
    
    init(moment: Moment) {
        name = moment.username!
        photoDescription = moment.description
        latitude = moment.latitude! 
        longitude = moment.longitude! 
        momentID = moment.id
        
        if let imageString = moment.thumbnail_base64 {
            let decodedData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            thumbnail = UIImage(data: decodedData!)
        } else {
            thumbnail = nil
        }
        
        date = NSDate(timeIntervalSince1970: moment.pub_time_interval!)
    }
    
    
    // MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? { return name }
    
    var subtitle: String? { return formatDate(date) }
}
