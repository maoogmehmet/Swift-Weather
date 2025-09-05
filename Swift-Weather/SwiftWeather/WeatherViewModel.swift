//
//  WeatherViewModel.swift
//  Created by Mehmet Özdede on 10/05/2025.
//  Copyright © 2025 Mehmet Özdede. All rights reserved.
//

import Foundation
import CoreLocation

class WeatherViewModel {
    // MARK: - Constants
    private let emptyString = ""

    // MARK: - Properties
    let hasError: Observable<Bool>
    let errorMessage: Observable<String?>

    let location: Observable<String>
    let iconText: Observable<String>
    let temperature: Observable<String>
    let forecasts: Observable<[ForecastViewModel]>

    // MARK: - Services
    private let locationService: LocationService
    private let weatherService: WeatherServiceProtocol

    // MARK: - init
    init(locationService: LocationService = LocationService(),
         weatherService: WeatherServiceProtocol = OpenWeatherMapService()) {
        hasError = Observable(false)
        errorMessage = Observable(nil)

        location = Observable(emptyString)
        iconText = Observable(emptyString)
        temperature = Observable(emptyString)
        forecasts = Observable([])

        self.locationService = locationService
        self.weatherService = weatherService
    }

    // MARK: - Public
    func startLocationService() {
        locationService.delegate = self
        locationService.requestLocation()
    }

    // MARK: - Private
    private func update(_ weather: Weather) {
        hasError.value = false
        errorMessage.value = nil

        location.value = weather.location
        iconText.value = weather.iconText
        temperature.value = weather.temperature
        forecasts.value = weather.forecasts.map { ForecastViewModel($0) }
    }

    private func update(_ error: SWError) {
        hasError.value = true
        errorMessage.value = error.userMessage
        resetWeatherData()
    }

    private func resetWeatherData() {
        location.value = emptyString
        iconText.value = emptyString
        temperature.value = emptyString
        forecasts.value = []
    }
}

// MARK: - LocationServiceDelegate
extension WeatherViewModel: LocationServiceDelegate {
    func locationDidUpdate(_ service: LocationService, location: CLLocation) {
        weatherService.retrieveWeatherInfo(location) { [weak self] (weather, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.update(error)
                    return
                }
                if let weather = weather {
                    self.update(weather)
                }
            }
        }
    }

    func locationDidFail(withError error: SWError) {
        update(error)
    }
}

// MARK: - SWError Extension for user-friendly messages
extension SWError {
    var userMessage: String {
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
