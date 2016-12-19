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

    override var description: String {
        return "\(name), \(length), \(unit)"
    }
    
    // MARK: - Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
    static let ArchiveURL = DocumentsDirectory!.appendingPathComponent("measure_reference")
    
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(length, forKey: PropertyKey.lengthKey)
        aCoder.encode(unit, forKey: PropertyKey.unitKey)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        let length = aDecoder.decodeDouble(forKey: PropertyKey.lengthKey)
        let unit = aDecoder.decodeObject(forKey: PropertyKey.unitKey) as! String
        
        self.init(name: name, length: length, unit: unit)
    }
    
    
}
