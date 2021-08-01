//
//  Helpers.swift
//  Practice_Weather_App
//
//  Created by fedir on 22.07.2021.
//

import UIKit
import Lottie

public func someWrongAlert(_ title: String ,_ message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(.init(title: "cancel", style: .destructive, handler: nil))
    return alert
}

public func getDayTimeFor(timeInterval interval: TimeInterval, withTimeZone offset: Float) -> Date {
    let userTimeZone = Float(TimeZone.current.secondsFromGMT())
    let dayTime = Date(timeIntervalSince1970: TimeInterval(interval)).addingTimeInterval(TimeInterval(offset - userTimeZone))
    return dayTime
}
