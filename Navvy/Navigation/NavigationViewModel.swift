//
//  NavigationViewModel.swift
//  Navvy
//
//  Created by Samuel Shi on 12/16/21.
//

import Combine
import MapKit

class NavigationViewModel: ObservableObject {
    let navigationManager: NavigationManager
    let destination: Destination

    @Published var angleToDestination: Double = 0
    @Published var distanceToDestination: String = ""
    @Published var accessibilityAngleDescription: String = ""
    
    private var distanceCancellable: AnyCancellable?
    private var angleCancellable: AnyCancellable?
    
    init(destination: Destination) {
        self.destination = destination
        navigationManager = NavigationManager(destination: destination)
        
        distanceCancellable = navigationManager.$distanceToDestination
            .map(NavigationViewModel.measurementToString)
            .weaklyAssign(to: \.distanceToDestination, on: self)
        
        angleCancellable = navigationManager.$angleToDestination
            .sink { [weak self] angle in
                self?.didUpdateAngle(angle: angle)
            }
    }
    
    func didUpdateAngle(angle: Double) {
        let angleInDegrees = angle * .pi / 180 // convert from radians to degrees
        angleToDestination = -angleInDegrees // display angle should flip sign to show which way the user should go
        
        let boundedAngle = NavigationViewModel.accessibilityHeading(angle: angle)
        let direction = NavigationViewModel.accessibilityHeadingDirection(angle: boundedAngle)
        
        if direction == "Left" || direction == "Right" {
            accessibilityAngleDescription = "Destination is \(abs(boundedAngle)) degrees to the \(direction)"
        } else {
            accessibilityAngleDescription = "Destination is \(direction)"
        }
    }
    
    var destinationName: String? { destination.name }
    var destinationSubtitle: String? { destination.address }
    var destinationCategory: MKPointOfInterestCategory? { destination.category }
    var destinationCoordinates: CLLocationCoordinate2D { destination.coordinates }
    var destinationPhoneNumber: String? { destination.phoneNumber }
    var destinationURL: URL? { destination.url }
}

// MARK: VoiceOver Extensions
extension NavigationViewModel {
    static func measurementToString(measurement: Measurement<UnitLength>) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = measurement.value > 1 ? 0 : 1
        
        let number = NSNumber(floatLiteral: measurement.value)
        let distance = formatter.string(from: number)!
        
        return "\(distance) \(measurement.unit.symbol)"
    }
    
    static func accessibilityHeading(angle: Double) -> Int {
        var sign: Int
        let positiveAngle: Int
        
        if angle < 0 {
            sign = -1
            positiveAngle = -1 * (Int(angle) % 360)
        } else {
            sign = 1
            positiveAngle = Int(angle) % 360
        }
        
        if angle > 180, angle < 360 {
            sign = -1
        }
        
        if positiveAngle >= 0, positiveAngle <= 180 {
            return Int(positiveAngle) * sign
        }
        
        let boundedAngle = (positiveAngle - 360) * -1
        return sign * boundedAngle
    }
    
    static func accessibilityHeadingDirection(angle: Int) -> String {
        if abs(angle) < 5 {
            return "Forwards"
        } else if abs(angle) > 175 {
            return "Backwards"
        } else if angle > 0 {
            return "Left"
        } else {
            return "Right"
        }
    }
}
