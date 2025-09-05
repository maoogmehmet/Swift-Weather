//
//  Created by Mehmet Özdede on 10/05/2025.
//  Copyright © 2025 Mehmet Özdede. All rights reserved.
//

import Foundation

struct Temperature {
  let degrees: String

  init(country: String, openWeatherMapDegrees: Double) {
    if country == "US" {
      degrees = String(TemperatureConverter.kelvinToFahrenheit(openWeatherMapDegrees)) + "\u{f045}"
    } else {
      degrees = String(TemperatureConverter.kelvinToCelsius(openWeatherMapDegrees)) + "\u{f03c}"
    }
  }
}
