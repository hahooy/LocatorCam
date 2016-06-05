//
//  Moment.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/5/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import Foundation

class Moment {
    var id: Int?
    var username: String?
    var description: String?
    var latitude: Double?
    var longitude: Double?
    var pub_time_interval: NSTimeInterval?
    var thumbnail_base64: String?
    
    init(id: Int?, username: String?, description: String?,
         latitude: Double?,
         longitude: Double?,
         pub_time_interval: NSTimeInterval?,
         thumbnail_base64: String?) {
        self.id = id
        self.username = username
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.pub_time_interval = pub_time_interval
        self.thumbnail_base64 = thumbnail_base64
    }
    
    convenience init() {
        self.init(id: nil,username: nil,description: nil,latitude: nil,longitude: nil,pub_time_interval: nil,thumbnail_base64: nil)
    }
}