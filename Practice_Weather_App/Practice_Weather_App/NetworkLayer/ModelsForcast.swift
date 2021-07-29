//
//  Models.swift
//  Practice_Weather_App
//
//  Created by fedir on 20.07.2021.
//

import Foundation

//весь файл погода на несколько дней

struct WeatherModelForcast: Codable {
    var cod: String?
    var message: Float?
    var cnt: Float?
    var list: [ListModelForcast]?
    var city: CityModelForcast?
}


struct ListModelForcast: Codable {
    var dt: Float?
    var main: MainForcast?
    var weather: [WeatherForcast]?
    var wind: Wind?
    var dt_txt: String?
}

struct WeatherForcast: Codable {
    var id: Float?
    var main: String?
    var description:String?
    var icon: String?
}

struct Wind: Codable {
    var speed: Float?
}

struct MainForcast: Codable {
    var temp: Float?
    var temp_min: Float?
    var temp_max: Float?
}

struct CityModelForcast:Codable {
    var id: Float?
    var name: String?
    var coord: Coordinate?
    var country: String?
    var population: Float?
    var timezone : Float?
    var sunrise: Float?
    var sunset: Float?
}

struct Coordinate: Codable {
    var lat: Float
    var lon: Float
}


