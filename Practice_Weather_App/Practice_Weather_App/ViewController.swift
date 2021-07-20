//
//  ViewController.swift
//  Practice_Weather_App
//
//  Created by Admin on 20.07.2021.
//

import UIKit

class ViewController: UIViewController {
    
    let weather = Networkmanager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        weather.getWeather(city: "London") { model in
            print(model?.list?.count , model?.list?[0])
        }
                           
    }


}

