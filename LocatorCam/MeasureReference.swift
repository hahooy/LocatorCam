//
//  MeasureReference.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/21/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import Foundation

class MeasureReference: NSObject, NSCoding
{
    // MARK: - Properties
    
    var name: String
    var length: Double
    var unit: String
    
    // MARK: - Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    static let ArchiveURL = DocumentsDirectory!.URLByAppendingPathComponent("measure_reference")
    
    // MARK: - Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let lengthKey = "length"
        static let unitKey = "unit"
    }
    
    // MARK: - Initialization
    init(name: String, length: Double, unit: String) {
        self.name = name
        self.length = length
        self.unit = unit
        
        super.init()
    }
    
    // MARK: - NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeDouble(length, forKey: PropertyKey.lengthKey)
        aCoder.encodeObject(unit, forKey: PropertyKey.unitKey)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let length = aDecoder.decodeDoubleForKey(PropertyKey.lengthKey)
        let unit = aDecoder.decodeObjectForKey(PropertyKey.unitKey) as! String
        
        self.init(name: name, length: length, unit: unit)
    }
}