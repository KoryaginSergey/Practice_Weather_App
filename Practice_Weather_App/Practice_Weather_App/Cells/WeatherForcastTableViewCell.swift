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
        
        print(forcast.weather?.first?.icon)
        let dayOfTheWeek = formatter.string(from: dayTimeInterval)
        dayOfTheWeekLabel.text = dayOfTheWeek
        weatherConditionIcon.image = UIImage(named: forcast.weather?.first?.icon ?? "")
            
        dayOfTheWeekTemperature.text = String(Int(forcast.main?.temp ?? 0.0))
    }
}
