//
//  Created by Mehmet Özdede on 10/05/2025.
//  Copyright © 2025 Mehmet Özdede. All rights reserved.
//

import Foundation

import Foundation

struct Weather: Decodable {
    let location: String
    let iconText: String
    let temperature: String
    let forecasts: [Forecast]
}

struct Forecast: Decodable {
    let date: Date
    let temp: String
    let icon: String
}

// Test / Mock verisi
extension Weather {
    static func mock() -> Weather {
        return Weather(
            location: "Istanbul",
            iconText: "☀️",
            temperature: "25°C",
            forecasts: [
                Forecast(date: Date(), temp: "24°C", icon: "🌤"),
                Forecast(date: Date().addingTimeInterval(86400), temp: "22°C", icon: "🌦")
            ]
        )
    }
}
