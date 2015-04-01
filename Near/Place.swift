//
//  Place.swift
//  Near
//
//  Created by Juho Salmio on 16/03/15.
//  Copyright (c) 2015 aalto. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Place: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var descriptionText: String
    @NSManaged var category: String
    @NSManaged var radius: Double
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var visited: Bool
    @NSManaged var lastVisit: NSDate
    @NSManaged var city: String

    func getVisitRadius() -> Double {
        return radius * 0.5
    }
    
    func isWithinVisitThreshold(location: CLLocation) -> Bool {
     
        return location.distanceFromLocation(CLLocation(latitude: latitude, longitude: longitude)) < getVisitRadius()
    }

}
