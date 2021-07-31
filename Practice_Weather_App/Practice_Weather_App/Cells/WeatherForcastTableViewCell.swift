//
//  WeatherForDaysAheadTableViewCell.swift
//  Practice_Weather_App
//
//  Created by Alex Han on 21.07.2021.
//

import UIKit

class WeatherForcastTableViewCell: UITableViewCell {

    @IBOutlet weak var dayOfTheWeekLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionIcon: UIImageView!
    @IBOutlet private var minTemperatureLabel: UILabel!
    
    //MARK: Убрать нил с картинки
    
    func setupWeatherForDaysCell(withForcast forcast: ListModelForcast) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let dayTimeInterval = Date(timeIntervalSince1970: TimeInterval(forcast.dt ?? 0.0))
        
        let dayOfTheWeek = formatter.string(from: dayTimeInterval)
        dayOfTheWeekLabel.text = dayOfTheWeek
        weatherConditionIcon.image = UIImage(named: forcast.weather?.first?.icon ?? "")
            
        maxTemperatureLabel.text = String(Int(forcast.main?.temp_max ?? 0.0))
        minTemperatureLabel.text = String(Int(forcast.main?.temp_min ?? 0.0))
    }
}
