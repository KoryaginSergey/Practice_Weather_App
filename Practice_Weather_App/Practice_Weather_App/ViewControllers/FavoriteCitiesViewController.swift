//
//  FavoriteCitiesViewController.swift
//  Practice_Weather_App
//
//  Created by Admin on 20.07.2021.
//

import UIKit
import CoreData
import Lottie


class FavoriteCitiesViewController: UIPageViewController {
    
    private var weatherVcs = [UIViewController]()
    private var defaultWeatherVcs = [UIViewController]()
    private var weatherAnimationView = AnimationView()
    private var backgroundImage: UIImageView?
    private let animationView = UIImageView()
    
        let background = UIImageView()

    private var models = [CDCityModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setAnimationView()
        self.configureNavigationButtons()
        self.setBackgroundImage()
        self.dataSource = self
        self.reloadViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weatherAnimationView.play()
    }
}

extension FavoriteCitiesViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.weatherVcs.firstIndex(of: viewController) {
            if index < weatherVcs.count - 1 {
                
                if let vc = weatherVcs[index + 1] as? CurrentLocationViewController {
                    vc.didLoadClosure = { [weak self] weather in
                        guard let self = self,
                              let current = weather,
                              let weatherConditionsID = current.weather?.first?.id,
                              let dayTimeInterval = current.dt,
                              let intervalForSunrise = current.sys?.sunrise,
                              let intervalForSunset = current.sys?.sunset
//                              let timeZone = current.timezone
                        else {
                            return
                        }
                        self.updateAnimation(conditionId: weatherConditionsID, forDayTimeInterval: TimeInterval(dayTimeInterval), bySunriseInterval: TimeInterval(intervalForSunrise), andSunsetInterval: TimeInterval(intervalForSunset))
                    }
                }
                
                return weatherVcs[index + 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.weatherVcs.firstIndex(of: viewController) {
            if index > 0 {
                if let vc = weatherVcs[index + 1] as? CurrentLocationViewController {
                    vc.didLoadClosure = { [weak self] weather in
                        guard let self = self,
                              let current = weather,
                              let weatherConditionsID = current.weather?.first?.id,
                              let dayTimeInterval = current.dt,
                              let intervalForSunrise = current.sys?.sunrise,
                              let intervalForSunset = current.sys?.sunset
//                              let timeZone = current.timezone
                        else {
                            return
                        }
                        self.updateAnimation(conditionId: weatherConditionsID, forDayTimeInterval: TimeInterval(dayTimeInterval), bySunriseInterval: TimeInterval(intervalForSunrise), andSunsetInterval: TimeInterval(intervalForSunset))
                    }
                }
                return weatherVcs[index - 1]
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        if weatherVcs.count > 0 {
            return self.weatherVcs.count
        } else {
            return 1
        }
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentVc = pageViewController.viewControllers?[0] else {
            return 0
        }
        return self.weatherVcs.firstIndex(of: currentVc) ?? 0
    }
    
}

private extension FavoriteCitiesViewController {
    
    private func reloadViewControllers() {
        self.fetchData()
        weatherVcs = createArrayVC()
        if weatherVcs.count > 0 {
            self.setViewControllers([weatherVcs[0]], direction: .forward, animated: false, completion: nil)
        } else {
            defaultWeatherVcs = createDefaultArrayVC()
            self.setViewControllers([defaultWeatherVcs[0]], direction: .forward, animated: false, completion: nil)
        }
        
        if let vc = self.viewControllers?.first as? CurrentLocationViewController {
            vc.didLoadClosure = { [weak self] weather in
            guard     let self = self,
                      let current = weather,
                      let weatherConditionsID = current.weather?.first?.id,
                      let dayTimeInterval = current.dt,
                      let intervalForSunrise = current.sys?.sunrise,
                      let intervalForSunset = current.sys?.sunset
//                      let timeZone = current.timezone
            else {
                    return
                }
                self.updateAnimation(conditionId: weatherConditionsID, forDayTimeInterval: TimeInterval(dayTimeInterval), bySunriseInterval: TimeInterval(intervalForSunrise), andSunsetInterval: TimeInterval(intervalForSunset))
            }
        }
    }
    
    private func configureNavigationButtons() {
        
        let origImage = UIImage(named: "add_to_favorites1")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        let moreButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        moreButton.setBackgroundImage(tintedImage, for: .normal)
        moreButton.tintColor = .white
        moreButton.addTarget(self, action: #selector(addButtonSelector), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
    }
    
    @objc private func addButtonSelector() {
        let storyboard = UIStoryboard(name: String(describing: SearchListViewController.self), bundle: nil)
        let searchVc = storyboard.instantiateViewController(identifier: String(describing: SearchListViewController.self)) as SearchListViewController
        searchVc.completion = {
            self.reloadViewControllers()
        }
        let navigation = UINavigationController(rootViewController: searchVc)
        navigation.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigation, animated: true, completion: nil)
    }
    
    private func fetchData() {
        let context = DataModels.sharedInstance.context
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        let fetchRequest = NSFetchRequest<CDCityModel>(entityName: "CDCityModel")
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            self.models = try context.fetch(fetchRequest)
        } catch {
            print("ERROR")
        }
    }
    
    private func createArrayVC() -> [UIViewController] {
        var weatherVcsArray = [UIViewController]()
        for model in models {
            guard let modelVC =
                    storyboard?.instantiateViewController(identifier: String(describing: CurrentLocationViewController.self))
                    as? CurrentLocationViewController else {continue}
            modelVC.settings =  Settings(cityName: model.name, showBackgroundImage: false)
            weatherVcsArray.append(modelVC)
        }
        return weatherVcsArray
    }
    
    private func createDefaultArrayVC() -> [UIViewController] {
        var weatherVcsArray = [UIViewController]()
        guard let modelVC =
                storyboard?.instantiateViewController(identifier: String(describing: CurrentLocationViewController.self))
                as? CurrentLocationViewController else {return weatherVcsArray}
        modelVC.settings = Settings(cityName: nil, showBackgroundImage: false)
        weatherVcsArray.append(modelVC)
        return weatherVcsArray
    }
    
    private func setBackgroundImage() {

        background.contentMode = .scaleAspectFill

        view.insertSubview(background, at: 0)
        background.frame = view.bounds
        background.image = UIImage(named: "Mountain")
        self.weatherAnimationView = self.setWeatherAnimation(with: "clear",
                                                               andFrame: self.view.bounds)
        background.addSubview(weatherAnimationView)
        self.backgroundImage = background
    }
    
    private func setWeatherAnimation(with name: String, andFrame frame: CGRect) -> AnimationView {
        let animationView = AnimationView()
        
        animationView.frame = frame
        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }
    
    private func updateAnimation(conditionId: Float,
                         forDayTimeInterval dayTimeInterval: TimeInterval,
                         bySunriseInterval sunriseInterval: TimeInterval,
                         andSunsetInterval sunsetInterval: TimeInterval) {
        
        weatherAnimationView.stop()
        weatherAnimationView.removeFromSuperview()
        var weatherAnimationNamed = getAnimationForWeather(conditionID: conditionId)
        if sunriseInterval < dayTimeInterval && sunsetInterval > dayTimeInterval {
        } else {
            weatherAnimationNamed = "night" + weatherAnimationNamed
        }
        weatherAnimationView = setWeatherAnimation(with: weatherAnimationNamed,
                                                   andFrame: self.view.bounds)
        animationView.addSubview(weatherAnimationView)
        weatherAnimationView.play()
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
    
    private func setAnimationView() {
        animationView.contentMode = .scaleAspectFill
        view.insertSubview(animationView, at: 1)
        animationView.frame = view.bounds
    }
}

