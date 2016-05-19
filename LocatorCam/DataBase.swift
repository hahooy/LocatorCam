//
//  DataBase.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/17/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import Foundation
import Firebase

struct DataBase {
    static let momentFirebaseRef = Firebase(url:"https://fishboard.firebaseio.com/dev/moments")
    static let photoFirebaseRef = Firebase(url:"https://fishboard.firebaseio.com/dev/photos")
}