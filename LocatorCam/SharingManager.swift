//
//  SharingManager.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/20/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import Foundation
import Firebase

class SharingManager {
    var items = [NSDictionary]()
    static let sharedInstance = SharingManager()
    
    struct Constant {
        static let NumberOfItemsToFetch: UInt = 10
        static let minimumTimeInterval = 0.000001
    }
}
