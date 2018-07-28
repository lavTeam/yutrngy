//
//  LocationService.swift
//  dmaker
//
//  Created by Aleksey Larichev on 01.06.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: Error)
}
var currentLocation: CLLocation?

class LocationService: NSObject, CLLocationManagerDelegate {
    static let instance = LocationService()
    
    var locationManager: CLLocationManager?
    var currentAccess: Bool? {
        willSet {
            currentAccess = newValue
        }
    }
    var delegate: LocationServiceDelegate?

    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000
        locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // передаем синглтону текущее местоположение
        currentLocation = location
        
        // Обновляем местоположение
        updateLocation(currentLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateLocationDidFailWithError(error: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CheckLocationAllow"), object: nil, userInfo: ["result": true])
                    self.currentAccess = true
                }
            }
        case .authorizedWhenInUse:
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CheckLocationAllow"), object: nil, userInfo: ["result": true])
                    self.currentAccess = true
                }
            }
        case .denied:
            self.currentAccess = false
        case .notDetermined:
            self.currentAccess = false
        case .restricted:
            self.currentAccess = false

        }
    }
    

 // protocol
    private func updateLocation(currentLocation: CLLocation){
        guard let delegate = self.delegate else {return}
        delegate.tracingLocation(currentLocation: currentLocation)
    }

    private func updateLocationDidFailWithError(error: Error) {
        guard let delegate = self.delegate else {return}
        delegate.tracingLocationDidFailWithError(error: error)
    }
    func requestAccessLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    
    
    
}
