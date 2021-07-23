//
//  NetworkManager.swift
//  Practice_Weather_App
//
//  Created by fedir on 20.07.2021.
//

import Foundation

//http://api.openweathermap.org/data/2.5/forecast?q=London&units=metric&appid=010490d0c60a959c36f0688641ada569
//http://api.openweathermap.org/data/2.5/weather?q=London&units=metric&appid=010490d0c60a959c36f0688641ada569
//http://api.openweathermap.org/geo/1.0/direct?q=London&limit=5&appid=010490d0c60a959c36f0688641ada569
//https://api.openweathermap.org/data/2.5/weather?lat=35&lon=139&units=metric&appid=76a212233b5863b7fe5c80277e71a5ba

//MARK: -  погода на сегодня или на несколько дней
private enum DownloadTask: String {
    case forecast
    case weather
    case weatherByLocation
}

private struct Api {
  static  let mainUrl: String = "https://api.openweathermap.org/data/"
  static  let id: String = "appid=76a212233b5863b7fe5c80277e71a5ba"
  static let id2: String = "appid=010490d0c60a959c36f0688641ada569"
}

enum WeatherURL {
    case forecast(name: String)
    case weatherToday(name: String)
    case weatherbyLocation(lat: Double,lon: Double)
    case direct(name: String)
    
    //http://api.openweathermap.org/data/2.5/forecast?q=London&units=metric&appid=010490d0c60a959c36f0688641ada569
    //http://api.openweathermap.org/data/2.5/weather?q=London&units=metric&appid=010490d0c60a959c36f0688641ada569
    //http://api.openweathermap.org/geo/1.0/direct?q=London&limit=5&appid=010490d0c60a959c36f0688641ada569
    //https://api.openweathermap.org/data/2.5/weather?lat=35&lon=139&units=metric&appid=76a212233b5863b7fe5c80277e71a5ba
    
    
    var url: String {
            switch self {
            case .forecast(let name): return Api.mainUrl+"forecast?q=\(name)&units=metric&"+Api.id
            case .weatherToday(let name):return Api.mainUrl+"weather?q=\(name)&units=metric&"+Api.id
            case .weatherbyLocation(let lon,let lat): return Api.mainUrl+"weather?\(lon)=35&\(lat)=139&units=metric&"+Api.id
            case .direct(let name): return  Api.mainUrl+"geo/1.0/direct?q=\(name)&limit=5&"+Api.id
        }
    }
}

class Networkmanager {
    
    private init() {}
    static let shared: Networkmanager = Networkmanager()
    
    
//    //MARK: - getURL
//    private func getUrl(_ task: DownloadTask ,city: String ) -> URL {
//        var urlcomponents = URLComponents()
//        urlcomponents.scheme = "https"
//        urlcomponents.host = "api.openweathermap.org"
//        urlcomponents.path = "/data/2.5/\(task)"
//        urlcomponents.queryItems = [URLQueryItem(name: "q", value: city),
//                                    URLQueryItem(name: "units", value: "metric"),
//                                    URLQueryItem(name: "appid", value: "010490d0c60a959c36f0688641ada569")]
//        return urlcomponents.url!
//    }
    
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
    
    //MARK: - weather for a few days
    func getForcastWeather(city: String, result: @escaping ((WeatherModelForcast?)->())) {
        if let url = URL(string: WeatherURL.forecast(name: city).url) {
        URLSession.shared.dataTask(with: url) { (data, responce, error) in
            guard  error == nil else {
                print("error: ",error?.localizedDescription as Any)
                return
            }
            DispatchQueue.main.async {
            result(self.decodejson(type: WeatherModelForcast.self , from: data))
            }
        }.resume()
     }
  }
    
    //MARK: - weather today
    func getCurrentWeather(city: String, result: @escaping ((CurrentWeather?)->())) {
        if let url = URL(string: WeatherURL.weatherToday(name: city).url) {
        URLSession.shared.dataTask(with: url){ (data, responce, error) in
            guard  error == nil else {
                print("error: ",error?.localizedDescription as Any)
                return
            }
            DispatchQueue.main.async {
            result(self.decodejson(type: CurrentWeather.self , from: data))
            }
        }.resume()
    }
}
    //MARK: - weather today by coordinate
    func getCurrentWeatherByLocation(lat: Double,lon: Double, result: @escaping ((CurrentWeather?)->())) {
        if let  url = URL(string: WeatherURL.weatherbyLocation(lat: lat, lon: lon).url) {
        URLSession.shared.dataTask(with: url) { (data, responce, error) in
            guard  error == nil else {
                print("error: ",error?.localizedDescription as Any)
                return
            }
            DispatchQueue.main.async {
            result(self.decodejson(type: CurrentWeather.self , from: data))
            }
        }.resume()}
    }
    
    //MARK: - description for choosen City
    func getListOfCities(by cityName: String, result: @escaping (([CityModel]?)->())) -> URLSessionDataTask? {
        guard let url = URL(string: WeatherURL.direct(name: cityName).url) else {
            result(nil)
            return nil
        }
        let task = URLSession.shared.dataTask(with: url) { (data, responce, error) in
            DispatchQueue.main.async {
                guard  error == nil else {
                    print("error: ",error?.localizedDescription as Any)
                    return
                }
                result(self.decodejson(type: [CityModel].self , from: data))
            }
        }
        task.resume()
        return task
    }
}
