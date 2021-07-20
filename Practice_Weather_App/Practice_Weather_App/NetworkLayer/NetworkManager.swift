//
//  NetworkManager.swift
//  Practice_Weather_App
//
//  Created by fedir on 20.07.2021.
//

import Foundation

//http://:api.openweathermap.org/data/2.5/forecast?q=London&units=metric&appid=010490d0c60a959c36f0688641ada569
//http://api.openweathermap.org/data/2.5/weather?lat=55.75&lon=37.61&units=metric&appid=010490d0c60a959c36f0688641ada569

class Networkmanager {
    
    //MARK: - делаем синглтон
    private init() {}
    static let shared: Networkmanager = Networkmanager()
    
    //MARK: - функция получения данных
    func getWeather(city: String, result: @escaping ((WeatherModel?)->())) {
        
        var urlcomponents = URLComponents()
        urlcomponents.scheme = "https"
        urlcomponents.host = "api.openweathermap.org"
        urlcomponents.path = "/data/2.5/forecast"
        urlcomponents.queryItems = [URLQueryItem(name: "q", value: city),
                                    URLQueryItem(name: "units", value: "metric"),
                                    URLQueryItem(name: "appid", value: "010490d0c60a959c36f0688641ada569")]
        
        var request = URLRequest(url: urlcomponents.url!)
        request.httpMethod = "GET"
        
        let task = URLSession(configuration: .default)
        task.dataTask(with: request) { (data, responce, error) in
            if error == nil  {
              let decoder = JSONDecoder()
              var decodeOffermodel:WeatherModel?
                if data != nil {
                    decodeOffermodel = try? decoder.decode(WeatherModel.self, from: data!)
                }
                result(decodeOffermodel)
            }else{
                print("error:",error as Any)
                result(nil)
            }
        }.resume()
    }
}
