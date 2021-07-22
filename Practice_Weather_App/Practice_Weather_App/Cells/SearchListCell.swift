//
//  SearchListCell.swift
//  Practice_Weather_App
//
//  Created by Admin on 20.07.2021.
//

import Foundation
import  UIKit


class SearchListCell: UITableViewCell {
  
    @IBOutlet weak var nameCityLabel: UILabel!
    @IBOutlet weak var viewForCell: UIView!
    
    
   public func setParamsViewForCell() {
        viewForCell.layer.cornerRadius = 15.0
        viewForCell.layer.borderWidth = 1.0
        viewForCell.layer.borderColor = UIColor.black.cgColor
    }
    
    
}
