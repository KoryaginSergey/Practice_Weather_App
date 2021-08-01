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
    @IBOutlet weak var nameCountryLabel: UILabel!
    
    
    public func setParamsViewForCell() {
        viewForCell.layer.cornerRadius = 15.0
    }
    
    
}
