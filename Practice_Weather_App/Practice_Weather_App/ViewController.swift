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
        //на несколько дней
        weather.getForcastWeather(city: "San Migel") { model in
            print(model?.list?.count ?? 0 , model?.list?[0])
        }
        //на сегодня
        weather.getCurrentWeather(city: "Лондон") { current in
            print("Name: ",current?.name)
            print(current?.weather)
            print(current?.sys)
        }
                           
    }


}

