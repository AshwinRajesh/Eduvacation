//
//  LocationData.swift
//  Eduvacation
//
//  Created by Ashwin Rajesh on 7/4/20.
//  Copyright © 2020 AshwinR. All rights reserved.
//

import UIKit

class LocationData: NSObject, NSCoding {
    
    var city: String
    var completed: [String]
    var percent: Int
    var done: Bool
    var lat: Float
    var lng: Float
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("locationData")
    
    struct PropertyKey {
        static let city = "city"
        static let completed = "completed"
        static let percent = "percent"
        static let done = "done"
        static let lat = "lat"
        static let lng = "lng"
    }
    
    init?(city: String, completed: [String], percent: Int, done: Bool, lat: Float, lng: Float) {
        
        // The name must not be empty
        guard !city.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (percent >= 0) && (percent <= 100) else {
            return nil
        }
        
        // Initialization should fail if there is no name or if the rating is negative.
        if city.isEmpty || percent < 0  {
            return nil
        }
        
        // Initialize stored properties.
        self.city = city
        self.completed = completed
        self.percent = percent
        self.done = done
        self.lng = lng
        self.lat = lat
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(city, forKey: PropertyKey.city)
        aCoder.encode(completed, forKey: PropertyKey.completed)
        aCoder.encode(percent, forKey: PropertyKey.percent)
        aCoder.encode(done, forKey: PropertyKey.done)
        aCoder.encode(lng, forKey: PropertyKey.lng)
        aCoder.encode(lat, forKey: PropertyKey.lat)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let city = aDecoder.decodeObject(forKey: PropertyKey.city) as? String else {
            print("Unable to decode the name for a Location object.")
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let completed = aDecoder.decodeObject(forKey: PropertyKey.completed) as? [String]
        
        let percent = aDecoder.decodeInteger(forKey: PropertyKey.percent)
        
        let done = aDecoder.decodeBool(forKey: PropertyKey.done)
        
        let lat = aDecoder.decodeFloat(forKey: PropertyKey.lat)
        
        let lng = aDecoder.decodeFloat(forKey: PropertyKey.lng)
        
        // Must call designated initializer.
        self.init(city: city, completed: completed!, percent: percent, done: done, lat: lat, lng: lng)
    }
    
}
