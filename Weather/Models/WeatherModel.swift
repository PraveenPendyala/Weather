//
//  WeatherModel.swift
//  Weather
//
//  Created by Praveen on 4/16/23.
//

import Foundation

struct WeatherModel: Decodable {
    
    var weather     : [WeatherCondition]
    var main        : MainWeather
    var visibility  : Double
    var wind        : WindCondition
    var clouds      : Clouds
    var sys         : SunInfo
    var name        : String
    
    struct WeatherCondition: Decodable {
        var main        : String
        var description : String
        var icon        : String
    }
    
    struct MainWeather: Decodable {
        var temp        : Double
        var feels_like  : Double
        var temp_min    : Double
        var temp_max    : Double
        var humidity    : Int
    }
    
    struct Clouds: Decodable {
        var all: Int
    }
    
    struct WindCondition: Decodable {
        var speed : Double
    }
    
    struct SunInfo: Decodable {
        var sunrise : Double
        var sunset  : Double
    }
}
