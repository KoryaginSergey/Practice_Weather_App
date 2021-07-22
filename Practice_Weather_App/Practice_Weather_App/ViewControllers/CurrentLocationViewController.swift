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
        setBackgroundImage()
        getDataFromServer()
        
    }
    
    private func getDataFromServer() {
       
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

    @objc func showMiracle() {
            let weatherForcast = GestureTableView()
        weatherForcast.modalPresentationStyle = .custom
        weatherForcast.transitioningDelegate = self
            self.present(weatherForcast, animated: true, completion: nil)
        }
        
        @IBAction func onButton(_ sender: Any) {
            showMiracle()
        }
    
}

extension CurrentLocationViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
