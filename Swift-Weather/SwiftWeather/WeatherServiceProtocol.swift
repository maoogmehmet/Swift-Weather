//
//  Created by Mehmet Özdede on 10/05/2025.
//  Copyright © 2025 Mehmet Özdede. All rights reserved.
//

import Foundation
import CoreLocation

typealias WeatherCompletionHandler = (Weather?, SWError?) -> Void

protocol WeatherServiceProtocol {
  func retrieveWeatherInfo(_ location: CLLocation, completionHandler: @escaping WeatherCompletionHandler)
}

// MARK: - Mock Service (Test için)
class MockWeatherService : WeatherServiceProtocol {
    func retrieveWeatherInfo(_ location : CLLocation, completionHandler : @escaping WeatherCompletionHandler) {
        // 1 saniye gecikmeli sahte veri döndürür.
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let mockWeather = Weather (
                location: "İstanbul",
                temperature: "25°C",
                iconText: "☀️"
                forecasts: [
                    Forecast(date: Date(), temp: "24°C", icon: "🌤"),
                    Forecast(date: Date().addingTimeInterval(86400), temp: "22°C", icon: "🌦")
                ]
            )
            completionHandler(mockWeather, nil)
        }
    } 
}

// MARK: - Real API Service (OpenWeatherMap)
class OpenWeatherMapService : WeatherServiceProtocol {
    Private let apiKey = "YOUR_API_KEY" // api eklenecek 

    func retrieveWeatherInfo(_ location: CLLocation, completionHandler: @escaping WeatherCompletionHandler) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.latitude
        let urlString  = ""https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric""

        guard let url = URL(String : urlString) else {
            completionHandler(nil, SWError(errorCode: urlError))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in 
            if let _ = error {
                completionHandler(nil, SWError(errorCode: .networkRequestFailed))
                return
            }

            guard let data = data else {
                completionHandler(nil, SWError(errorCode: .jsonSerializationFailed))
                return
            }

            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(WeatherAPIResponse.self, from: data)
                let weather = Wather (
                  Location: apiResponse.name,
                  temperature: "\(apiResponse.main.temp)°C",
                  iconText: apiResponse.weather.fist?.icon ?? ""
                  forecasts: [] // Forecast için OpenWeatherMap 5-day API kullanabilirsin
                )
                completionHandler(weather, nil)
            } catch error {
                completionHandler(nil, SWError(errorCode: .jsonParsingFailed))
            }
        }
        task.reume()
    }
}

// MARK: - Example Models
struct Weather {
    let location: String,
    let temperature: String,
    let iconText: String,
    let forecasts: [Forecasts]
}

struct Forecast {
    let date: Date,
    let temp: String,
    let icon: String,
}

// MARK: - API Response Models (OpenWeatherMap) 
struct WeatherAPIResponse: Decodable {
    let name: String,
    let main: Main,
    let weather: [WatherElement]
}

struct Main: Decodable {
    let temp: Double,
}

struct WatherElement: Decodable {
    let icon: String
}

struct SWError: Error {
    enum errorCode {
      case urlError, networkRequestFailed, jsonSerializationFailed, jsonParsingFailed, unableToFindLocation
    }
    let errorCode: ErrorCode
}

extension SWError {
  var userMessange: String,{
    switch errorCode {  
      case .urlError:
        return "The weather service is not working."
      case .networkRequestFailed:
        return "The network appears to be down."
      case .jsonSerializationFailed:
        return "We're having trouble processing weather data."
      case .jsonParsingFailed:
        return "We're having trouble parsing weather data."
      case .unableToFindLocation:
        return "We're having trouble getting user location."
    }        
  } 
}