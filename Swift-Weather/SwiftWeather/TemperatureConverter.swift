//
//  Created by Mehmet Özdede on 10/05/2025.
//  Copyright © 2025 Mehmet Özdede. All rights reserved.
//

import Foundation

struct TemperatureConverter {
  static func kelvinToCelsius(_ degrees: Double) -> Double {
    return round(degrees - 273.15)
  }

  static func kelvinToFahrenheit(_ degrees: Double) -> Double {
    return round(degrees * 9 / 5 - 459.67)
  }
}
