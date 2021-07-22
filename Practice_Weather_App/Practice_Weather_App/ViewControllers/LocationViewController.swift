//
//  ViewController.swift
//  Practice_Weather_App
//
//  Created by Admin on 20.07.2021.
//

import UIKit

    
   

class LocationViewController: UIViewController {
    
    let weather = Networkmanager.shared

    @IBOutlet private weak var currentLocationLabel: UILabel!
    @IBOutlet private weak var weatherConditionLabel: UILabel!
    
    @IBOutlet private weak var temperatureLabel: UILabel!
    private var weatherForcast: [ListModelForcast]?
    private let cellID = String(describing: WeatherForDaysAheadTableViewCell.self)
    @IBOutlet weak var forcastTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forcastTableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        
        setBackgroundImage()
        getDataFromServer()
        
    }

    func getDataFromServer() {
       
        weather.getForcastWeather(city: "Лондон") { [weak self] weatherForcastData in
            guard let self = self,
                  let forcast = weatherForcastData?.list
                   else {
                return
            }
            DispatchQueue.main.async {
                self.weatherForcast = forcast
                self.forcastTableView.reloadData()
            }
        }
        
        
        weather.getCurrentWeather(city: "Харьков") { [weak self] current in
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
        
        background.contentMode = .scaleToFill
        
        view.insertSubview(background, at: 0)
        background.translatesAutoresizingMaskIntoConstraints = false
        background.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        background.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        background.image = UIImage(named: "Mountain")
    }
}



extension LocationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rowsCount = weatherForcast?.count else {
            return 0
        }
        return rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let forcastData = weatherForcast?[indexPath.row],
              let day = forcastData.dt_txt,
              let temperature = forcastData.main?.temp,
              let weatherCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? WeatherForDaysAheadTableViewCell else {
            return WeatherForDaysAheadTableViewCell()
        }
                
        
        weatherCell.setupWeatherForDaysCell(dayOfTheWeek: day, conditionIcon: nil, temperature: String(temperature))
        
        
        
       return weatherCell
    }
    
        
    
}
