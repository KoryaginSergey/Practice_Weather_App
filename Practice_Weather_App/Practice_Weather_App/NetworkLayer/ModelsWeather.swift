//
//  ModelsWeather.swift
//  Practice_Weather_App
//
//  Created by fedir on 21.07.2021.
//

import Foundation

struct CurrentWeather: Codable {
    var weather: [Weather]?
    var main: Main?
    var wind: Wind?
    var sys: System?
    var dt: Float?
    var timezone: Float?
    var name: String?
}

struct Weather: Codable {
    var id: Float?
    var main: String?
    var description: String?
    var icon: String?
}

struct Main: Codable {
    var temp: Float
    var temp_min: Float
    var temp_max: Float
    var pressure: Float
    var humidity: Float
}

struct System: Codable {
    var country: String
    var sunrise: Float
    var sunset: Float
}
