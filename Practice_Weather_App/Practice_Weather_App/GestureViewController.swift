//
//  File.swift
//  Practice_Weather_App
//
//  Created by Alex Han on 22.07.2021.
//

import UIKit

class GestureViewController: UIViewController {
    
    @IBOutlet private weak var weatherForcastTableView: UITableView!
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    private let cellID = String(describing: WeatherForcastTableViewCell.self)
    private var weatherForcast: [ListModelForcast]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadForcast()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        weatherForcastTableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    override func viewDidLayoutSubviews() {
        
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    private func loadForcast() {
        
        Networkmanager.shared.getForcastWeather(city: "Лондон") { [weak self] weatherForcastData in
            guard let self = self,
                  let forcast = weatherForcastData?.list
            else {
                return
            }
            
            DispatchQueue.main.async {
                self.weatherForcast = forcast
                self.weatherForcastTableView.reloadData()
            }
        }
    }
    
    @objc private func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        guard translation.y >= 0 else { return }
        
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}


extension LocationViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension GestureViewController: UITableViewDataSource {
    
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
              let weatherCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? WeatherForcastTableViewCell else {
            return WeatherForcastTableViewCell()
        }
        
        weatherCell.setupWeatherForDaysCell(dayOfTheWeek: day, conditionIcon: nil, temperature: String(temperature))
        
        return weatherCell
    }
}
