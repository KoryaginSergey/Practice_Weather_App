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
    @NSManaged public var id: Int16

}

extension CDCityModel : Identifiable {

    static func getCity(by name: String?) -> CDCityModel? {
        let context = DataModels.sharedInstance.context
        let predicate = NSPredicate(format: "name == %@", name as! CVarArg)
        let fetchRequest = NSFetchRequest<CDCityModel>(entityName: String(describing: CDCityModel.self))
        fetchRequest.predicate = predicate
        let cities = try? context.fetch(fetchRequest)
        
        return cities?.first
    }
    
    static func objectNumber() -> Int {
        let context = DataModels.sharedInstance.context
        let fetchRequest = NSFetchRequest<CDCityModel>(entityName: String(describing: CDCityModel.self))
        let cities = try? context.fetch(fetchRequest)
        
        return cities?.count ?? 0
    }
    
}
