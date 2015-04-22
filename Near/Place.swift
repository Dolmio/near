//
//  Place.swift
//  Near
//
//  Created by Juho Salmio on 16/03/15.
//  Copyright (c) 2015 aalto. All rights reserved.
//

import Foundation
import CoreData

class Place: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var city: String
    @NSManaged var descriptionText: String
    @NSManaged var category: String
    @NSManaged var radius: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var visited: Bool
    @NSManaged var lastVisit: NSDate

}
