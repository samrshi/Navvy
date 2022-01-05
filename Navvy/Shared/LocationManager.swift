//
//  LocationManager.swift
//  Navigation
//
//  Created by Samuel Shi on 8/17/21.
//

import Combine
import CoreLocation
import Foundation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()

    let locationsPublisher = PassthroughSubject<[CLLocation], Never>()
    let headingPublisher = PassthroughSubject<CLHeading, Never>()
    let errorPublisher = PassthroughSubject<Error?, Never>()

    init(desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBestForNavigation) {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = desiredAccuracy

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationsPublisher.send(locations)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        headingPublisher.send(newHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorPublisher.send(error)
    }

    func requestPreciseLocation() {
        if locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "ForDirections") { error in
                print(error.debugDescription)
            }
        }
    }
}
