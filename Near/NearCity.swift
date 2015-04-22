//
//  NearCity.swift
//  Near
//
//  Created by Lauri on 14/04/15.
//  Copyright (c) 2015 aalto. All rights reserved.
//

import Foundation
import CoreData

class NearCity: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber

}
