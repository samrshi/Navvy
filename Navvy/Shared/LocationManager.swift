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

    @Published var locations: [CLLocation] = []
    @Published var heading: CLHeading = CLHeading()
    let errorPublisher = PassthroughSubject<Error?, Never>()

    var userLocation: CLLocationCoordinate2D?
    
    init(desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBestForNavigation) {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = desiredAccuracy

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
        self.locations = locations
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading
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
    
    var locationPermissionsAreDenied: Bool {
        locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted
    }
}
