//
//  CurrentLocationViewController.swift
//  Practice_Weather_App
//
//  Created by Alex Han on 20.07.2021.
//

import UIKit
import CoreLocation
import Lottie

private struct Constant {
    static let locationOff = "Geolocation is off"
    static let geopositionBanned = "You have banned to use geoposition"
    static let cancel = "Cancel"
    static let allow = "Allow?"
    static let turnOn = "Turn on?"
    static let minTemp = "min.Temperature"
    static let maxTemp = "max.Temperature"
    static let windSpeed = "wind speed"
    static let patToPrefs = "App-Prefs:root=LOCATION_SERVICES"
}

struct Settings {
    var cityName: String?
    let showBackgroundImage: Bool
    
    static func getDefaultSettings() -> Settings {
        let settings = Settings(cityName: nil, showBackgroundImage: true)
        return settings
    }
}

class CurrentLocationViewController: UIViewController {
    
    @IBOutlet weak var descriptionView: UIView!
    private var isLocationState: Bool = false
    private let locationManager = CLLocationManager()
    private var currentWeather: CurrentWeather? {
        didSet {
            self.didLoadClosure?(currentWeather)
        }
    }
    private var weatherAnimationView = AnimationView()
    private let backgroundView = UIImageView()
    
    @IBOutlet private weak var currentLocationLabel: UILabel!
    @IBOutlet private weak var weatherConditionLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var sunriseTimeLabel: UILabel!
    @IBOutlet private weak var sunsetTimeLabel: UILabel!
    @IBOutlet private weak var sunriseImageView: UIImageView!
    @IBOutlet private weak var sunsetImageView: UIImageView!
    
    var cityNameForForcast: String?
    
    public var didLoadClosure: ((CurrentWeather?) -> ())?
    
    @IBOutlet weak var weatherDescription: UILabel!
    
    var settings: Settings = Settings.getDefaultSettings()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViewController()
        self.descriptionView.roundedCorners(withRadius: 10)
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.didLoadClosure?(currentWeather)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isLocationState { startLocationManager() }
        weatherAnimationView.play()
    }
    
    private func getDataFromServer(cityName: String) {
        Networkmanager.shared.getCurrentWeather(city: cityName) { [weak self] current in
            guard let current = current else {return}
            DispatchQueue.main.async {
                self?.currentWeather = current
                self?.updateUI(withAnimation: false)
            }
        }
    }
    
    
    // MARK: функция создания анимации
    private func setWeatherAnimation(with name: String, andFrame frame: CGRect) -> AnimationView {
        
        weatherAnimationView.frame = frame
        weatherAnimationView.animation = Animation.named(name)
        weatherAnimationView.contentMode = .scaleAspectFill
        weatherAnimationView.loopMode = .loop
        
        return weatherAnimationView
    }
    
    private func getAnimationForWeather(conditionID: Float) -> String {
        var jsonName: String
        
        switch conditionID {
            case 200 ... 202, 210 ... 212, 221, 230 ... 232:
                jsonName = "thunderstorm"
            case 313, 314, 321, 502 ... 504, 520 ... 522, 531:
                jsonName = "rainfall"
            case 300 ... 302, 310 ... 312, 500, 501:
                jsonName = "rain"
            case 511, 611, 612, 615, 616:
                jsonName = "snowandrain"
            case 600 ... 602:
                jsonName = "snow"
            case 620 ... 622:
                jsonName = "blizzard"
            case 711, 721, 741:
                jsonName = "fog"
            case 800:
                jsonName = "clear"
            case 801 ... 803:
                jsonName = "cloudsandsun"
            case 701, 804:
                jsonName = "clouds"
            default:
                jsonName = ""
        }
        
        return jsonName
    }
    
    
    private func setBackground() {
        backgroundView.contentMode = .scaleAspectFill
        view.insertSubview(backgroundView, at: 0)
        backgroundView.frame = view.bounds
        backgroundView.backgroundColor = UIColor(displayP3Red: 0.82,
                                                 green: 0.87,
                                                 blue: 0.96,
                                                 alpha: 1)
    }
    
    func presentForcast() {
        
        let weatherForcastVC = GestureViewController()
        weatherForcastVC.forcastForCityNamed = self.settings.cityName
        weatherForcastVC.modalPresentationStyle = .custom
        weatherForcastVC.transitioningDelegate = self
        self.present(weatherForcastVC, animated: true, completion: nil)
        
        let weatherForcast = GestureViewController()
        weatherForcast.modalPresentationStyle = .custom
        weatherForcast.transitioningDelegate = self
        self.present(weatherForcast, animated: true, completion: nil)
    }
}


extension CurrentLocationViewController {
    
    private func configureViewController() {
        
        if let cityName = self.settings.cityName {
            getDataFromServer(cityName: cityName)
        } else {
            self.isLocationState = true
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
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = 100
            locationManager.pausesLocationUpdatesAutomatically = false
            checkAutorisation()
            
        }else{
            self.locationAlert(title: Constant.locationOff,
                               message: Constant.turnOn,
                               url: URL(string: Constant.patToPrefs ))
        }
    }
    
    func checkAutorisation() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways:
                break
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            case .denied:
                self.locationAlert(title:Constant.geopositionBanned,
                                   message: Constant.allow,
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
        alert.addAction(.init(title: Constant.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - CLLocationManagerDelegate
extension CurrentLocationViewController: CLLocationManagerDelegate {
    //MARK: - request of coordinate when changing location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            print(lastLocation.coordinate.latitude , lastLocation.coordinate.longitude)
            let lat = lastLocation.coordinate.latitude
            let lon = lastLocation.coordinate.longitude
            
            Networkmanager.shared.getCurrentWeatherByLocation(lat: lat, lon: lon) { [weak self] current in
                
                guard let self = self,
                      let current = current
                else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.currentWeather = current
                    self.updateUI(withAnimation: true)
                    self.locationManager.stopUpdatingLocation()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        startLocationManager()
    }
}

private extension CurrentLocationViewController {
    
    func updateUI(withAnimation: Bool) {
        
        guard let current = self.currentWeather,
              let currentLocationName = current.name,
              let temperature = current.main?.temp,
              let weatherConditionsID = current.weather?.first?.id,
              let main = current.main,
              let windSpeed = current.wind?.speed,
            //  let weatherDescription = current.weather?.first?.description,
              let dayTimeInterval = current.dt,
              let country = current.sys?.country,
              let intervalForSunrise = current.sys?.sunrise,
              let intervalForSunset = current.sys?.sunset,
              let timeZone = current.timezone else {
            return
        }
        settings.cityName = currentLocationName
        
        
        // делаем сдвиг по временной зоне, чтобы отобразить по времени локации, а не времени устройства
        let sunriseTime = getDayTimeFor(timeInterval: TimeInterval(intervalForSunrise),
                                        withTimeZone: timeZone)
        let sunsetTime = getDayTimeFor(timeInterval: TimeInterval(intervalForSunset),
                                       withTimeZone: timeZone)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        formatter.dateFormat = "HH:mm"
        
        updateBackgroundImage(forTenperature: Int(temperature))
        
        self.currentLocationLabel.text = currentLocationName
        self.weatherConditionLabel.text = WeatherDataSource.weatherIDs[Int(floor(weatherConditionsID))]
        self.temperatureLabel.text = String(Int(temperature)) + " ºC"
        let formattedSunriseTime = formatter.string(from: sunriseTime)
        self.sunriseTimeLabel.text = formattedSunriseTime
        let formattedSunsetTime = formatter.string(from: sunsetTime)
        self.sunsetTimeLabel.text = formattedSunsetTime
        
        //weatherDescription.capitalizedFirstLatter()
        
        self.weatherDescription.text = "Country: \(country)" + "\ntodays max temperature " + String(Int(main.temp_max)) + " ºC" + "\ntodays min temperature " + String(Int(main.temp_min)) + " ºC" + "\nwind speed " + String(windSpeed) + " m/sec"
        
        // передаем интервалы времени рассвета\заката уже со свдигом по временной зоне
        if withAnimation {
            updateAnimation(conditionId: weatherConditionsID,
                            forDayTimeInterval: TimeInterval(dayTimeInterval),
                            bySunriseInterval: TimeInterval(intervalForSunrise),
                            andSunsetInterval: TimeInterval(intervalForSunset))
        }
        
    }
    
    func updateAnimation(conditionId: Float,
                         forDayTimeInterval dayTimeInterval: TimeInterval,
                         bySunriseInterval sunriseInterval: TimeInterval,
                         andSunsetInterval sunsetInterval: TimeInterval) {
        
        // должно быть var для того, чтобы модифицировать имя json которое записалось
        var weatherAnimationNamed = getAnimationForWeather(conditionID: conditionId)
        
        // если текущее время локации попадает в промежуток от рассвета до заката локации, то if не выполнится
        if !(sunriseInterval < dayTimeInterval && sunsetInterval > dayTimeInterval) {
            weatherAnimationNamed = "night" + weatherAnimationNamed
        }
        weatherAnimationView = setWeatherAnimation(with: weatherAnimationNamed,
                                                   andFrame: self.view.bounds)
        
        backgroundView.addSubview(weatherAnimationView)
        weatherAnimationView.play()
        
    }
    
    func updateBackgroundImage(forTenperature: Int) {
        self.sunriseImageView.image = UIImage(named: "sunrise")
        self.sunsetImageView.image = UIImage(named: "sunset")
        switch forTenperature {
            case (-15) ... 0:
                self.backgroundView.image = UIImage(named: "littlemin")
            case ...(-16) :
                self.backgroundView.image = UIImage(named: "bigmin")
            default:
                self.backgroundView.image = UIImage(named: "Mountain")
        }
        
    }
    
}
