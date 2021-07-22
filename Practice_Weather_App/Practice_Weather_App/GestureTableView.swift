//
//  File.swift
//  Practice_Weather_App
//
//  Created by Alex Han on 22.07.2021.
//

import UIKit

class GestureTableView: UIViewController {
    
    @IBOutlet weak var weatherForcastTableView: UITableView!
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    let cellID = String(describing: WeatherForDaysAheadTableViewCell.self)

    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
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
    
    
}

extension GestureTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let rowsCount = weatherForcast?.count else {
//            return 0
//        }
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        guard let forcastData = weatherForcast?[indexPath.row],
//              let day = forcastData.dt_txt,
//              let temperature = forcastData.main?.temp,
//              let weatherCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? WeatherForDaysAheadTableViewCell else {
//            return WeatherForDaysAheadTableViewCell()
//        }
//
//
//        weatherCell.setupWeatherForDaysCell(dayOfTheWeek: day, conditionIcon: nil, temperature: String(temperature))
        
        
        guard let weatherCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? WeatherForDaysAheadTableViewCell else {
            return WeatherForDaysAheadTableViewCell()
        }
        //            return WeatherForDaysAheadTableViewCell()
        //        }
        //
        
       return weatherCell
    }
}
