//
//  CurrentLocationViewController.swift
//  Practice_Weather_App
//
//  Created by Alex Han on 20.07.2021.
//

import UIKit

class CurrentLocationViewController: UIViewController {
    
    

    
    @IBOutlet private weak var currentLocationLabel: UILabel!
    @IBOutlet private weak var weatherConditionLabel: UILabel!
    
    @IBOutlet private weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Networkmanager.shared.getCurrentWeatherByLocation(lat: 50, lon: 36.15) {[weak self] weather in
            DispatchQueue.main.async {
                self?.currentLocationLabel.text = weather?.name
            }
        }
        setBackgroundImage()
        //getDataFromServer()
        
    }

    func getDataFromServer() {
       
        Networkmanager.shared.getCurrentWeather(city: "Харьков") { [weak self] current in
            guard let self = self,
                  let currentLocation = current?.name,
                  let weatherConditionsID = current?.weather?[0].id,
                  let temperature = current?.main?.temp else {
                return
            }
            
            DispatchQueue.main.async {
                
                self.currentLocationLabel.text = currentLocation
                self.weatherConditionLabel.text = WeatherDataSource.weatherIDs[Int(floor(weatherConditionsID))]
                self.temperatureLabel.text = String(Int(temperature)) + " ºC"
            }
        }
        
    }
    func setBackgroundImage() {
        
        let background = UIImageView()
        
        background.contentMode = .scaleToFill // Or w/e your desired content mode is
        
        view.insertSubview(background, at: 0)
        background.translatesAutoresizingMaskIntoConstraints = false
        background.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        background.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        background.image = UIImage(named: "Mountain")
    }

}
