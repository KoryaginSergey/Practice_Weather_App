//
//  CurrentLocationViewController.swift
//  Practice_Weather_App
//
//  Created by Alex Han on 20.07.2021.
//

import UIKit
import CoreLocation
import Lottie

struct Settings {
    let cityName: String?
    let showBackgroundImage: Bool
    
    static func getDefaultSettings() -> Settings {
        let settings = Settings(cityName: nil, showBackgroundImage: true)
        return settings
    }
}

class CurrentLocationViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var currentWeather: CurrentWeather?
    private var weatherAnimationView: AnimationView?
    private let backgroundView = UIImageView()
    
    
    
    @IBOutlet private weak var currentLocationLabel: UILabel!
    @IBOutlet private weak var weatherConditionLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var sunriseTimeLabel: UILabel!
    @IBOutlet private weak var sunsetTimeLabel: UILabel!
    @IBOutlet private weak var sunriseImageView: UIImageView!
    @IBOutlet private weak var sunsetImageView: UIImageView!
    
    var cityNameForForcast: String?
    
    @IBOutlet weak var weatherDescription: UILabel!
    
    var settings: Settings = Settings.getDefaultSettings()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViewController()
        
        //MARK: Картинки для теста заката/рассвета.
        self.sunriseImageView.image = UIImage(named: "Free-Weather-Icons_03")
        self.sunsetImageView.image = UIImage(named: "Free-Weather-Icons_22")
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        if let animation = weatherAnimationView {
            self.backgroundView.addSubview(animation)    // добавление анимации
            animation.play()                            // и запуск
        }
    }
    
    //MARK: Убрать старую ф-цию getDataFromServer() если не нужна
    private func getDataFromServer(cityName: String) {
        Networkmanager.shared.getCurrentWeather(city: cityName) { [weak self] current in
            guard let current = current else {return}
            DispatchQueue.main.async {
                self?.currentWeather = current
                self?.updateUI()
            }
        }
    }
    
    
    private func setBackground() {
        
        backgroundView.contentMode = .scaleAspectFill
        view.insertSubview(backgroundView, at: 0)
        backgroundView.frame = view.bounds
        backgroundView.image = UIImage(named: "Mountain")
        
        
        
        
    }
    // MARK: функция создания анимации
    private func setWeatherAnimation(with name: String, andFrame frame: CGRect) -> AnimationView {
        let animationView = AnimationView()
        
        animationView.frame = frame
        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        
        return animationView
    }
    
    func presentForcast() {
        
        let weatherForcastVC = GestureViewController()
        weatherForcastVC.forcastForCityNamed = cityNameForForcast
        weatherForcastVC.modalPresentationStyle = .custom
        weatherForcastVC.transitioningDelegate = self
        self.present(weatherForcastVC, animated: true, completion: nil)
        
        let weatherForcast = GestureViewController()
        weatherForcast.modalPresentationStyle = .custom
        weatherForcast.transitioningDelegate = self
        self.present(weatherForcast, animated: true, completion: nil)
    }
}

//MARK: -  locationManager
extension CurrentLocationViewController {
    
    private func configureViewController() {
        
        if let cityName = self.settings.cityName {
            getDataFromServer(cityName: cityName)
        } else {
            startLocationManager()
        }
        
        if self.settings.showBackgroundImage {
            setBackground()
        } else {
            self.view.backgroundColor = UIColor.clear
        }
        
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
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func checkAutorisation() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways:
                break
            case .authorizedWhenInUse:
                locationManager.startMonitoringSignificantLocationChanges()
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
    //MARK: - request of coordinate when changing location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("--------------------->>")
        if let lastLocation = locations.last {
            print(lastLocation.coordinate.latitude , lastLocation.coordinate.longitude)
            let lat = lastLocation.coordinate.latitude
            let lon = lastLocation.coordinate.longitude
            
            Networkmanager.shared.getCurrentWeatherByLocation(lat: lat, lon: lon) { [weak self] current in
                
                guard let self = self,
                      let currentLocation = current?.name,
                      let weatherConditionsID = current?.weather?.first?.id,
                      let main = current?.main
                else {
                    return
                }
                
                DispatchQueue.main.async {
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .none
                    formatter.timeStyle = .medium
                    formatter.dateFormat = "HH:mm"
                    
                    self.cityNameForForcast = currentLocation
                    self.currentLocationLabel.text = currentLocation
                    self.weatherConditionLabel.text = WeatherDataSource.weatherIDs[Int(floor(weatherConditionsID))]
                    self.temperatureLabel.text = String(Int(main.temp)) + " ºC"
                    
                    guard let current = current else {return}
                    
                    self.currentWeather = current
                    self.updateUI()
                    
                    // определяем нужную анимацию
                    let weatherAnimationNamed = getAnimationForWeather(conditionID: weatherConditionsID)
                    self.weatherAnimationView = self.setWeatherAnimation(with: weatherAnimationNamed,
                                                                           andFrame: self.view.bounds)
                    
                    self.locationManager.stopMonitoringSignificantLocationChanges()
                }
            }
        }
    }
}

private extension CurrentLocationViewController {
    
    func updateUI() {
        guard let current = self.currentWeather else {return}
        
        guard let currentLocation = current.name,
              let weatherConditionsID = current.weather?.first?.id,
              let main = current.main,
              let windSpeed = current.wind?.speed,
              let weatherDescription = current.weather?.first?.description,
              let intervalForSunrise = current.sys?.sunrise,
              let intervalForSunset = current.sys?.sunset else {
            return
        }
      
            let sunriseTimeInterval = Date(timeIntervalSince1970: TimeInterval(intervalForSunrise))
            let sunsetTimeInterval = Date(timeIntervalSince1970: TimeInterval(intervalForSunset))
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .medium
            formatter.dateFormat = "HH:mm"
            
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
    
    func getCurrentTimeForLocation() {
        
    }
}
