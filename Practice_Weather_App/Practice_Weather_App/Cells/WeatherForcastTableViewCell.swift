//
//  WeatherForDaysAheadTableViewCell.swift
//  Practice_Weather_App
//
//  Created by Alex Han on 21.07.2021.
//

import UIKit

class WeatherForcastTableViewCell: UITableViewCell {

    @IBOutlet weak var dayOfTheWeekLabel: UILabel!
    @IBOutlet weak var dayOfTheWeekTemperature: UILabel!
    @IBOutlet weak var weatherConditionIcon: UIImageView!
    
    
    //MARK: Убрать нил с картинки
    
    func setupWeatherForDaysCell(dayOfTheWeek: String, conditionIcon: UIImage?, temperature: String) {
        dayOfTheWeekLabel.text = dayOfTheWeek
        weatherConditionIcon.image = conditionIcon
        dayOfTheWeekTemperature.text = temperature
    }
}
