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

public func getDescribe(_ codeOfWeather: Int) -> String {
    switch codeOfWeather {
    case 200,201,202: return "гроза с дождем"
    case 210,211,212,221: return "гроза"
    case 230,231,232: return "ливень и изморось"
    case 300,301: return "мелкий дождь"
    case 302,310,311,312: return "моросящий дождь"
    case 313,314: return "ливень и изморозь"
    case 500,501: return "умеренный дождь"
    case 321,502,503,504,520,521,522,531: return "очень сильный дождь"
    case 511: return "ледянной дождь"
    case 600,601,602: return "снег"
    case 611,612,615,616: return "дождь со снегом"
    case 620...622: return "снегопад"
    case 701,711,722: return "дымка"
    case 741: return "туман"
    case 731,751,761: return "пылевая буря"
    case 762: return "вулканический пепел"
    case 771: return "шквал"
    case 781: return "торнадо"
    case 800: return "чистое небо"
    case 801...804: return "облачно"

    default: return "веедены некоректные данные"
    }
}


public func getAnimationForWeather(conditionID: Float) -> String {
    switch conditionID {
        case 200 ... 221:
            return "thunderstorm"
        case 230 ... 232, 313, 314, 321, 502 ... 504, 520 ... 522, 531:
            return "rainfall"
        case 300 ... 302, 310 ... 312, 500, 501:
            return "rain"
        case 511, 611, 612, 616:
            return "snowandrain"
        case 600 ... 602:
            return "snow"
        case 620 ... 622:
            return "blizzard"
        case 711, 722,741:
            return "fog"
        case 701:
            return "cloudsandsun"
        case 801 ... 804:
            return "clouds"
        default:
            return "clear"  // чистое небо
    }
}


public func setWeatherAnimation(with name: String, andFrame frame: CGRect) -> AnimationView {
    let animationView = AnimationView()
    
    animationView.frame = frame
    animationView.animation = Animation.named(name)
    animationView.contentMode = .scaleAspectFill
    animationView.loopMode = .loop   
    
    return animationView
}
