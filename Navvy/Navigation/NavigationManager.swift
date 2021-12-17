//
//  LocationManager.swift
//  Navigation
//
//  Created by Samuel Shi on 5/20/21.
//

import Combine
import MapKit

class NavigationManager: ObservableObject {
    private lazy var locationManager: LocationManager = {
        let locationManager = LocationManager()
        return locationManager
    }()
    
    @Published var distanceToDestination: Measurement = Measurement(value: 0, unit: UnitLength.miles)
    @Published var angleToDestination: Double = 0
    @Published var userHeading: Double = 0
    @Published var error: Error? = nil

    private var destination: CLLocation
    private var userLocation = CLLocation()
    private var cancellables = [AnyCancellable]()
    
    init(mapItem: MKMapItem) {
        guard let location = mapItem.placemark.location else {
            fatalError("Provided MKMapItem did not contain a CLLocation")
        }
        
        destination = location
        locationManager.requestPreciseLocation()
        
        locationManager.locationsPublisher
            .sink { [weak self] locations in
                self?.didUpdateLocations(locations: locations)
            }
            .store(in: &cancellables)
        
        locationManager.headingPublisher
            .sink { [weak self] heading in
                self?.didUpdateHeading(newHeading: heading)
            }
            .store(in: &cancellables)
        
        locationManager.errorPublisher
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
    }

    func didUpdateLocations(locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.angleToDestination = calculateAngle(to: destination, from: location)
        self.userLocation = location
        
        let distance = location.distance(from: destination)
        let unit: UnitLength = distance <= 500 ? .feet : .miles
        let distanceConverted = Measurement(value: distance, unit: UnitLength.meters).converted(to: unit)
        
        self.distanceToDestination = distanceConverted
    }

    func didUpdateHeading(newHeading: CLHeading) {
        userHeading = newHeading.magneticHeading
        self.angleToDestination = calculateAngle(to: destination, from: userLocation)
    }

    func calculateAngle(to destination: CLLocation, from location: CLLocation) -> Double {
        let angle = userHeading - location.angleTo(destination: destination)
        return angle
    }
}
