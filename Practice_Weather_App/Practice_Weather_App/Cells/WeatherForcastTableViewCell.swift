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
    
    func setupWeatherForDaysCell(withForcast forcast: ListModelForcast) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let dayTimeInterval = Date(timeIntervalSince1970: TimeInterval(forcast.dt ?? 0.0))
        
        
        let dayOfTheWeek = formatter.string(from: dayTimeInterval)
        dayOfTheWeekLabel.text = dayOfTheWeek
        weatherConditionIcon.image = nil
            //MARK: сделать округгление к целому числу
        dayOfTheWeekTemperature.text = String(forcast.main?.temp ?? 0.0)
    }
}
