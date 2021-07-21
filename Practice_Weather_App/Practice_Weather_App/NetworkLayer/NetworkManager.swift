//
//  NetworkManager.swift
//  Practice_Weather_App
//
//  Created by fedir on 20.07.2021.
//

import Foundation

//http://api.openweathermap.org/data/2.5/forecast?q=London&units=metric&appid=010490d0c60a959c36f0688641ada569
//http://api.openweathermap.org/data/2.5/weather?q=London&units=metric&appid=010490d0c60a959c36f0688641ada569


//MARK: -  погода на сегодня или на несколько дней
private enum DownloadTask: String {
    case forecast
    case weather
}

class Networkmanager {
    
    private init() {}
    static let shared: Networkmanager = Networkmanager()
    
    // получение урл с возможностью выбора задачи на день или на несколько
  private func getUrl(_ task: DownloadTask ,city: String ) -> URL {
        var urlcomponents = URLComponents()
        urlcomponents.scheme = "https"
        urlcomponents.host = "api.openweathermap.org"
        urlcomponents.path = "/data/2.5/\(task)"
        urlcomponents.queryItems = [URLQueryItem(name: "q", value: city),
                                    URLQueryItem(name: "units", value: "metric"),
                                    URLQueryItem(name: "appid", value: "010490d0c60a959c36f0688641ada569")]
        return urlcomponents.url!
    }
    //MARK: - univarsal decodable function
    func decodejson<T:Decodable>(type: T.Type, from: Data?) -> T? {
    let decoder = JSONDecoder()
        guard let data = from else { return nil }
        
        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let error {
            print("data has been not decoded : \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    //MARK: - погода на несколько дней
    func getForcastWeather(city: String, result: @escaping ((WeatherModelForcast?)->())) {
        var request = URLRequest(url: getUrl(.forecast, city: city))
        request.httpMethod = "GET"
        let task = URLSession(configuration: .default)
        task.dataTask(with: request) { (data, responce, error) in
            DispatchQueue.main.async {
            result(self.decodejson(type: WeatherModelForcast.self , from: data))
            }
            
        }.resume()
    }
    
    func getCurrentWeather(city: String, result: @escaping ((CurrentWeather?)->())) {
        var request = URLRequest(url: getUrl( .weather, city: city))
        request.httpMethod = "GET"
        let task = URLSession(configuration: .default)
        task.dataTask(with: request) { (data, responce, error) in
            DispatchQueue.main.async {
            result(self.decodejson(type: CurrentWeather.self , from: data))
            }
        }.resume()
    }}
