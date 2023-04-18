//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Praveen on 4/16/23.
//

import Foundation
import CoreLocation

protocol WeatherViewModelDelegate: NSObjectProtocol {
    func configureView()
    func notifyUser(_ message: String)
}

class WeatherViewModel: NSObject {
    
    private var locationManager : CLLocationManager
    var weatherModel            : WeatherModel?
    weak var delegate           : WeatherViewModelDelegate?
    var cityName                : String? { return weatherModel?.name }
    var temperature             : String? { getTempString(weatherModel?.main.temp) }
    var weatherDescription      : String? { weatherModel?.weather.first?.main }
    var tempHighest             : String? { "High: " + getTempString(weatherModel?.main.temp_max) }
    var tempLowest              : String? { "Low: " + getTempString(weatherModel?.main.temp_min) }
    var tempFeelsLike           : String? { getTempString(weatherModel?.main.feels_like) }
    var humidity                : String? { if let humidity = weatherModel?.main.humidity { return "\(humidity)%" } else { return "--%"} }
    var windSpeed               : String? { if let speed = weatherModel?.wind.speed {return "\(speed) mph"} else { return "--"} }
    var cloudiness              : String? { if let cloudiness = weatherModel?.clouds.all { return "\(cloudiness)%" } else { return "--%"} }
    
    var imageName               : String {
        guard let icon = weatherModel?.weather.first?.icon else { return "" }
        return "https://openweathermap.org/img/wn/\(icon)@2x.png"
    }
    
    var visibility              : String? {
        if let visibility = weatherModel?.visibility {
            // converting meters to miles
            return String(format: "%.1f", visibility * 0.0006) + " mi"
        }
        else {
            return "--"
        }
    }
    var sunriseTime             : String? {
        if let time = weatherModel?.sys.sunrise {
            return Date(timeIntervalSince1970: time).dateStringWithFormat()
        }
        else {
            return "--"
        }
    }
    var sunsetTime             : String? {
        if let time = weatherModel?.sys.sunset {
            return Date(timeIntervalSince1970: time).dateStringWithFormat()
        }
        else {
            return "--"
        }
    }
    
    func getTempString(_ temp: Double?) -> String {
        if let temp = temp {
            return String(format: "%.0f", temp)+"\u{00B0}F"
        }
        else {
            return "--\u{00B0}F"
        }
    }
    
    init(_ locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager          = locationManager
    }
    
    
    // MARK: -
    // MARK: Public Methods
    
    func loadDefaultLocation() {
        // set location manager delegate
        self.locationManager.delegate = self
        if !loadLastCityIfAvailable() {
            // if there is no last searched city load users current location
            requestUserLocation()
        }
    }
    
    private func requestUserLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func loadLastCityIfAvailable() -> Bool {
        if let city = UserDefaults.standard.value(forKey: "lastCity") as? String {
            fetchWeatherInfo(city)
            return true
        }
        return false
    }
    
    // downloading wheter data, this can be done a separate networking layer
    func fetchWeather(_ lat: Double, _ long: Double) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=c3aa7036125bdd2473f499eb8283300f&units=imperial") else { return }
        makeWeatherAPICall(url)
    }
    
    func fetchWeatherInfo(_ city: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city),US&appid=c3aa7036125bdd2473f499eb8283300f&units=imperial") else { return }
        // Storing city name to user defaults
        UserDefaults.standard.set(city, forKey: "lastCity")
        makeWeatherAPICall(url)
    }
    
    func makeWeatherAPICall(_ url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            // Check that we received data
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.delegate?.notifyUser("Something Went Wrong. Please try again later!")
                }
                return
            }
            
            // Check for a successful response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self?.decodeInvalidResponse(data)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                self?.weatherModel = try decoder.decode(WeatherModel.self, from: data)
                DispatchQueue.main.async {
                    self?.delegate?.configureView()
                }
            } catch let error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self?.delegate?.notifyUser("Something Went Wrong. Please try again later!")
                }
            }
        }.resume()
    }
    
    func decodeInvalidResponse(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let error = try decoder.decode(ErrorModel.self, from: data)
            DispatchQueue.main.async {
                self.delegate?.notifyUser(error.message.capitalized)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// Delegate methods to access device location

extension WeatherViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        manager.stopUpdatingLocation()
        manager.delegate = nil
        self.fetchWeather(location.coordinate.latitude, location.coordinate.longitude)
    }
}
