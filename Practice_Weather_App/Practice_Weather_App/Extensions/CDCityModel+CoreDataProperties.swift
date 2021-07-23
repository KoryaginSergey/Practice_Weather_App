//
//  CDCityModel+CoreDataProperties.swift
//  Practice_Weather_App
//
//  Created by Admin on 22.07.2021.
//
//

import Foundation
import CoreData


extension CDCityModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCityModel> {
        return NSFetchRequest<CDCityModel>(entityName: "CDCityModel")
    }

    @NSManaged public var name: String?
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float

}

extension CDCityModel : Identifiable {

}
