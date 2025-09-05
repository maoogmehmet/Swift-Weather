//
//  LocationService.swift
//  Created by Mehmet Özdede on 10/05/2025.
//  Copyright © 2025 Mehmet Özdede. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - Authorization Types
enum LocationAuthorizationType {
    case whenInUse
    case always
}

// MARK: - Custom Error
enum LocationServiceError: Error {
    case authorizationDenied
    case unableToFindLocation
    case unknown
}

// MARK: - Authorization Status Mapping
enum LocationAuthorizationStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedWhenInUse
    case authorizedAlways
    
    init(clStatus: CLAuthorizationStatus) {
        switch clStatus {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .authorizedWhenInUse: self = .authorizedWhenInUse
        case .authorizedAlways: self = .authorizedAlways
        @unknown default: self = .notDetermined
        }
    }
}

// MARK: - Delegate Protocol
protocol LocationServiceDelegate: AnyObject {
    func locationService(_ service: LocationService, didUpdate location: CLLocation)
    func locationService(_ service: LocationService, didFail error: LocationServiceError)
    func locationService(_ service: LocationService, didChangeAuthorization status: LocationAuthorizationStatus)
}

// MARK: - Location Service
class LocationService: NSObject {
    weak var delegate: LocationServiceDelegate?
    
    private let locationManager = CLLocationManager()
    
    var authorizationType: LocationAuthorizationType = .whenInUse
    var accuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters {
        didSet { locationManager.desiredAccuracy = accuracy }
    }
    var distanceFilter: CLLocationDistance = kCLDistanceFilterNone {
        didSet { locationManager.distanceFilter = distanceFilter }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = accuracy
        locationManager.distanceFilter = distanceFilter
    }
    
    func requestAuthorization() {
        switch authorizationType {
        case .whenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .always:
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func requestLocation() {
        requestAuthorization()
        locationManager.requestLocation()
    }
}

// MARK: - Async/Await API
@available(iOS 15.0, *)
extension LocationService {
    func requestCurrentLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            let asyncDelegate = AsyncLocationDelegate(continuation: continuation)
            self.delegate = asyncDelegate
            self.requestLocation()
        }
    }
}

@available(iOS 15.0, *)
private class AsyncLocationDelegate: NSObject, LocationServiceDelegate {
    let continuation: CheckedContinuation<CLLocation, Error>
    
    init(continuation: CheckedContinuation<CLLocation, Error>) {
        self.continuation = continuation
    }
    
    func locationService(_ service: LocationService, didUpdate location: CLLocation) {
        continuation.resume(returning: location)
    }
    
    func locationService(_ service: LocationService, didFail error: LocationServiceError) {
        continuation.resume(throwing: error)
    }
    
    func locationService(_ service: LocationService, didChangeAuthorization status: LocationAuthorizationStatus) {
        if case .denied = status {
            continuation.resume(throwing: LocationServiceError.authorizationDenied)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            delegate?.locationService(self, didUpdate: location)
        } else {
            delegate?.locationService(self, didFail: .unableToFindLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationService(self, didFail: .unableToFindLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let mappedStatus = LocationAuthorizationStatus(clStatus: status)
        delegate?.locationService(self, didChangeAuthorization: mappedStatus)
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let mappedStatus = LocationAuthorizationStatus(clStatus: manager.authorizationStatus)
        delegate?.locationService(self, didChangeAuthorization: mappedStatus)
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}
