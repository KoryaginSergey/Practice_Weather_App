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
    @IBOutlet private weak var sunriseTimeLabel: UILabel!
    @IBOutlet private weak var sunsetTimeLabel: UILabel!
    
    @IBOutlet private weak var sunriseImageView: UIImageView!
    @IBOutlet private weak var sunsetImageView: UIImageView!
    @IBOutlet weak var weatherDescription: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sunriseImageView.image = UIImage(named: "Free-Weather-Icons_03")
        self.sunsetImageView.image = UIImage(named: "Free-Weather-Icons_22")
        
        
        setBackgroundImage()
        getDataFromServer()
    }
    
    private func getDataFromServer() {
        
        Networkmanager.shared.getCurrentWeather(city: "Харьков") { [weak self] current in
            guard let self = self,
                  let currentLocation = current?.name,
                  let weatherConditionsID = current?.weather?[0].id,
                  let main = current?.main,
                  let windSpeed = current?.wind?.speed,
                  let weatherDescription = current?.weather?[0].description,
                  let intervalForSunrise = current?.sys?.sunrise,
                  let intervalForSunset = current?.sys?.sunset else {
                return
            }
            
            DispatchQueue.main.async {
                let sunriseTimeInterval = Date(timeIntervalSince1970: TimeInterval(intervalForSunrise))
                let sunsetTimeInterval = Date(timeIntervalSince1970: TimeInterval(intervalForSunset))
                
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .medium
                
                self.currentLocationLabel.text = currentLocation
                self.weatherConditionLabel.text = WeatherDataSource.weatherIDs[Int(floor(weatherConditionsID))]
                self.temperatureLabel.text = String(Int(main.temp)) + " ºC"
                
                let formattedSunriseTime = formatter.string(from: sunriseTimeInterval)
                self.sunriseTimeLabel.text = formattedSunriseTime
                
                let formattedSunsetTime = formatter.string(from: sunsetTimeInterval)
                self.sunsetTimeLabel.text = formattedSunsetTime
                
                //MARK: Для теста мин/макс температуры
                self.weatherDescription.text = weatherDescription + ", максимальная температура " + String(main.temp_max) + ", минимальная температура  " + String(main.temp_min) + ", скорость ветра " + String(windSpeed) + " м/сек"
            }
        }
        
    }
    private func setBackgroundImage() {
        
        let background = UIImageView()
        
        background.contentMode = .scaleToFill
        
        view.insertSubview(background, at: 0)
        background.translatesAutoresizingMaskIntoConstraints = false
        background.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        background.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        background.image = UIImage(named: "Mountain")
    }

    func presentForcast() {
            let weatherForcast = GestureViewController()
        weatherForcast.modalPresentationStyle = .custom
        weatherForcast.transitioningDelegate = self
            self.present(weatherForcast, animated: true, completion: nil)
        }
        
        @IBAction func didTapPresentForcast(_ sender: Any) {
            presentForcast()
        }
    
}

extension CurrentLocationViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
