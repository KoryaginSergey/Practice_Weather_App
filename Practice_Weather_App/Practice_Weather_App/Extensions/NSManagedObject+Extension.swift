//
//  NSManagedObject+Extension.swift
//  Practice_Weather_App
//
//  Created by Admin on 27.07.2021.
//

import Foundation
import CoreData
import UIKit

extension NSManagedObject {
    
    static func createObject<T: NSManagedObject>() -> T {
        let context = DataModels.sharedInstance.context
        let entity = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: context)!
        let model = T(entity: entity, insertInto: context)
        
        return model
    }
    
}

extension String {
    func capitalizedFirstLatter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizingFirstLatter() {
        self = self.capitalizedFirstLatter()
    }
}

extension UIView {
    
    func roundedCorners(withRadius: CGFloat) {
        self.layer.cornerRadius = withRadius
        self.layer.masksToBounds = true
    }
}
