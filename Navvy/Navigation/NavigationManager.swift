//
//  LocationManager.swift
//  Navigation
//
//  Created by Samuel Shi on 5/20/21.
//

import Combine
import MapKit

class NavigationManager: ObservableObject {
    private lazy var locationManager = LocationManager.shared
    
    @Published var distanceToDestination = Measurement(value: 0, unit: UnitLength.miles)
    @Published var angleToDestination: Double = 0
    @Published var userHeading: Double = 0
    @Published var error: Error? = nil

    private var destination: CLLocation
    private var userLocation = CLLocation()
    private var locationsCancellable: AnyCancellable?
    private var headingCancellable: AnyCancellable?
    private var errorCancellable: AnyCancellable?
    
    let mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        guard let location = mapItem.placemark.location else {
            fatalError("Provided MKMapItem did not contain a CLLocation")
        }
        
        self.mapItem = mapItem
        
        destination = location
        locationManager.requestPreciseLocation()
        
        locationsCancellable = locationManager.locationsPublisher
            .sink { [weak self] locations in
                self?.didUpdateLocations(locations: locations)
            }
        
        headingCancellable = locationManager.headingPublisher
            .sink { [weak self] heading in
                self?.didUpdateHeading(newHeading: heading)
            }
        
        errorCancellable = locationManager.errorPublisher
            .weaklyAssign(to: \.error, on: self)
    }

    func didUpdateLocations(locations: [CLLocation]) {
        guard let location = locations.last else { return }
        angleToDestination = calculateAngle(to: destination, from: location)
        userLocation = location
        
        let distance = location.distance(from: destination)
        var unit: UnitLength!
        
        switch SettingsStore.shared.systemUnits {
        case .imperial:
            unit = distance <= 160 ? .feet : .miles
        case .metric:
            unit = distance <= 500 ? .meters : .kilometers
        }
        
        let distanceConverted = Measurement(value: distance, unit: UnitLength.meters).converted(to: unit)
        distanceToDestination = distanceConverted
    }

    func didUpdateHeading(newHeading: CLHeading) {
        userHeading = newHeading.magneticHeading
        angleToDestination = calculateAngle(to: destination, from: userLocation)
    }

    func calculateAngle(to destination: CLLocation, from location: CLLocation) -> Double {
        let angle = userHeading - location.angleTo(destination: destination)
        return angle
    }
}
