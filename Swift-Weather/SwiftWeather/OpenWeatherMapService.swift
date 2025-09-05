//
//  Created by Mehmet Özdede on 10/05/2025.
//  Copyright © 2025 Mehmet Özdede. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

// MARK: - Protocol
protocol WeatherServiceProtocol {
    func retrieveWeatherInfo(_ location: CLLocation) async throws -> Weather
}

// MARK: - OpenWeatherMapService
struct OpenWeatherMapService: WeatherServiceProtocol {
    
    private let urlPath = "https://api.openweathermap.org/data/2.5/forecast"
    
    func retrieveWeatherInfo(_ location: CLLocation) async throws -> Weather {
        guard let url = generateRequestURL(location) else {
            throw SWError(errorCode: .urlError)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // HTTP Status kontrolü
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw SWError(errorCode: .networkRequestFailed)
        }
        
        // JSON decode
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(WeatherAPIResponse.self, from: data)
        
        // Weather objesi oluştur
        return buildWeather(from: apiResponse)
    }
    
    // MARK: - Helper Functions
    private func buildWeather(from apiResponse: WeatherAPIResponse) -> Weather {
        // İlk liste elemanını kullan
        let firstItem = apiResponse.list.first!
        let temp = Temperature(country: apiResponse.city.country,
                               openWeatherMapDegrees: firstItem.main.temp)
        let weatherIcon = WeatherIcon(condition: firstItem.weather.first!.id,
                                      iconString: firstItem.weather.first!.icon)
        
        let forecasts = apiResponse.list.prefix(4).compactMap { item -> Forecast? in
            guard let weather = item.weather.first else { return nil }
            let temp = Temperature(country: apiResponse.city.country,
                                   openWeatherMapDegrees: item.main.temp)
            let icon = WeatherIcon(condition: weather.id, iconString: weather.icon)
            let time = ForecastDateTime(date: item.dt, timeZone: .current).shortTime
            return Forecast(time: time, iconText: icon.iconText, temperature: temp.degrees)
        }
        
        return Weather(location: apiResponse.city.name,
                       iconText: weatherIcon.iconText,
                       temperature: temp.degrees,
                       forecasts: Array(forecasts))
    }
    
    private func generateRequestURL(_ location: CLLocation) -> URL? {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let parameters = NSDictionary(contentsOfFile: filePath),
              let appId = parameters["OWMAccessToken"] as? String else {
            return nil
        }
        
        var components = URLComponents(string: urlPath)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: "\(location.coordinate.latitude)"),
            URLQueryItem(name: "lon", value: "\(location.coordinate.longitude)"),
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "units", value: "metric")
        ]
        
        return components?.url
    }
}

// MARK: - API Response Models
struct WeatherAPIResponse: Decodable {
    struct City: Decodable { let name: String; let country: String }
    struct ListItem: Decodable {
        struct Main: Decodable { let temp: Double }
        struct Weather: Decodable { let id: Int; let icon: String }
        let dt: TimeInterval
        let main: Main
        let weather: [Weather]
    }
    
    let city: City
    let list: [ListItem]
}

// MARK: - Weather / Forecast Models
struct Weather {
    let location: String
    let iconText: String
    let temperature: String
    let forecasts: [Forecast]
}

struct Forecast {
    let time: String
    let iconText: String
    let temperature: String
}

// MARK: - Error
struct SWError: Error {
    enum ErrorCode { case urlError, networkRequestFailed, jsonSerializationFailed, jsonParsingFailed, unableToFindLocation }
    let errorCode: ErrorCode
}

extension SWError {
    var userMessage: String {
        switch errorCode {
        case .urlError: return "The weather service is not working."
        case .networkRequestFailed: return "The network appears to be down."
        case .jsonSerializationFailed: return "We're having trouble processing weather data."
        case .jsonParsingFailed: return "We're having trouble parsing weather data."
        case .unableToFindLocation: return "We're having trouble getting user location."
        }
    }
}
