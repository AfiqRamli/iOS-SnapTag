//
//  Location+CoreDataProperties.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 12/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var latitude: Double
    @NSManaged public var locationDescription: String
    @NSManaged public var longitude: Double
    @NSManaged public var photoID: NSNumber?
    @NSManaged public var placemark: CLPlacemark?

}
