//
//  NetworkManager.swift
//  Practice_Weather_App
//
//  Created by fedir on 20.07.2021.
//

import Foundation

//https://api.openweathermap.org/data/2.5/forecast?q=London&units=metric&appid=010490d0c60a959c36f0688641ada569
//https://api.openweathermap.org/data/2.5/weather?q=London&units=metric&appid=010490d0c60a959c36f0688641ada569
//https://api.openweathermap.org/geo/1.0/direct?q=London&limit=1&appid=010490d0c60a959c36f0688641ada569
//https://api.openweathermap.org/data/2.5/weather?lat=35&lon=139&units=metric&appid=76a212233b5863b7fe5c80277e71a5ba


private struct Api {
    static  let mainUrlGeo: String = "https://api.openweathermap.org/geo/"
    static  let mainUrl: String = "https://api.openweathermap.org/data/"
    static  let id: String = "appid=76a212233b5863b7fe5c80277e71a5ba"
    static let id2: String = "appid=010490d0c60a959c36f0688641ada569"
}

enum WeatherURL {
    case forecast(name: String)
    case weatherToday(name: String)
    case weatherbyLocation(lat: Double,lon: Double)
    case direct(name: String)
    
    var url: String {
        switch self {
        case .forecast(let name): return Api.mainUrl+"2.5/forecast?q=\(name.replacingOccurrences(of:" ", with: "%20"))&units=metric&"+Api.id
        case .weatherToday(let name):return Api.mainUrl+"2.5/weather?q=\(name.replacingOccurrences(of:" ", with: "%20"))&units=metric&"+Api.id
        case .weatherbyLocation(let lat,let lon): return Api.mainUrl+"2.5/weather?lat=\(lat)&lon=\(lon)&units=metric&"+Api.id
        case .direct(let name): return  Api.mainUrlGeo+"/1.0/direct?q=\(name.replacingOccurrences(of:" ", with: "%20"))&limit=3&"+Api.id2
        }
    }
}

class Networkmanager {
    
    private init() {}
    static let shared: Networkmanager = Networkmanager()
    
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
    //MARK: -  create urlsession
    
    func urlSession(_ urlStr: String ,result: @escaping ((Data?) -> ()) ) {
        if let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { (data, responce, error) in
                guard  error == nil else {
                    print("error: ",error?.localizedDescription as Any)
                    return
                }
                    result(data)
            }.resume()
        }
    }
    
    
    //MARK: - weather for a few days
    func getForcastWeather(city: String, result: @escaping ((WeatherModelForcast?)->())) {
        urlSession(WeatherURL.forecast(name: city).url) { data in
            DispatchQueue.main.async {
                result(self.decodejson(type: WeatherModelForcast.self, from: data))
            }
        }
    }
    
    //MARK: - weather today
    func getCurrentWeather(city: String, result: @escaping ((CurrentWeather?)->())) {
        urlSession(WeatherURL.weatherToday(name: city).url) { data in
            DispatchQueue.main.async {
            result(self.decodejson(type: CurrentWeather.self, from: data))
            }
        }
    }
    //MARK: - weather today by coordinate
    func getCurrentWeatherByLocation(lat: Double,lon: Double, result: @escaping ((CurrentWeather?)->())) {
        urlSession(WeatherURL.weatherbyLocation(lat: lat, lon: lon).url) { data in
            DispatchQueue.main.async {
            result(self.decodejson(type: CurrentWeather.self, from: data))
            }
        }
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
