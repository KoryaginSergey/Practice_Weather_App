//
//  CurrentLocationViewController.swift
//  Practice_Weather_App
//
//  Created by Alex Han on 20.07.2021.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {
    
    let locationManager = CLLocationManager()

    @IBOutlet private weak var currentLocationLabel: UILabel!
    @IBOutlet private weak var weatherConditionLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setBackgroundImage()
        getDataFromServer()
        
    }
    
    //MARK: - функцию настройки местоположения вызывать сдесь
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLocationManager()
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

//MARK: -  locationManager
private extension CurrentLocationViewController {
    
    //MARK: - start settings for cllLocationManager
    func startLocationManager() {
        locationManager.requestWhenInUseAuthorization()//запрос положения когда приложение используется
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = 100
            locationManager.pausesLocationUpdatesAutomatically = false
            checkAutorisation()
        }else{
            self.locationAlert(title: "Геопозиционирование выключено",
                        message: "разрешить?",
                            url: URL(string:"App-Prefs:root=LOCATION_SERVICES"))
        }
    }
    
    
     func checkAutorisation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            self.locationAlert(title: "Вы запретили использование геопозиции",
                        message: "разрешить?",
                            url: URL(string: UIApplication.openSettingsURLString))
        case .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
        
    }
    
    //MARK: - alert "go to location settings"
    func locationAlert(title: String ,message: String,url: URL?) {
      let alert = UIAlertController(title: title, message: message , preferredStyle:.alert)
            alert.addAction(.init(title: title, style: .default, handler: { alert in
                if let url = url{
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }))
                alert.addAction(.init(title: "отмена", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
    }
}



//MARK: - CLLocationManagerDelegate
extension CurrentLocationViewController: CLLocationManagerDelegate {
    
  //  запрос координат при смене местоположения на расстояние указанное в настройках
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            print(lastLocation.coordinate.latitude , lastLocation.coordinate.longitude)
            let lat = lastLocation.coordinate.latitude
            let lon = lastLocation.coordinate.longitude
            
            Networkmanager.shared.getCurrentWeatherByLocation(lat: lat, lon: lon) { [weak self] current in
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
    }
}


