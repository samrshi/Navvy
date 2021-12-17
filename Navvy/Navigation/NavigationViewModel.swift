//
//  NavigationViewModel.swift
//  Navvy
//
//  Created by Samuel Shi on 12/16/21.
//

import Combine
import MapKit

class NavigationViewModel: ObservableObject {
    private var navigationManager: NavigationManager
    private var cancellables = [AnyCancellable]()
    
    @Published var angleToDestination: Double = 0
    @Published var distanceToDestination: String = ""
    @Published var accessibilityAngleDescription: String = ""

//    @Published var distanceUnit: String = "mi"
    
    @Published var userHeading: Double = 0
    
    @Published var showErrorScreen: Bool = false
    
    init(mapItem: MKMapItem) {
        self.navigationManager = NavigationManager(mapItem: mapItem)
        
        navigationManager.$distanceToDestination
            .map(measurementToString)
            .assign(to: \.distanceToDestination, on: self)
            .store(in: &cancellables)
        
        navigationManager.$angleToDestination
            .sink(receiveValue: didUpdateAngle)
            .store(in: &cancellables)
        
        navigationManager.$userHeading
            .assign(to: \.userHeading, on: self)
            .store(in: &cancellables)
    }
    
    func measurementToString(measurement: Measurement<UnitLength>) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = measurement.value > 1 ? 0 : 1
        
        let number = NSNumber(floatLiteral: measurement.value)
        let distance = formatter.string(from: number)!
        
        return "\(distance) \(measurement.unit.symbol)"
    }
    
    func didUpdateAngle(angle: Double) {
        angleToDestination = angle
        
        let boundedAngle = NavigationViewModel.accessibilityHeading(angle: angle)
        let direction = NavigationViewModel.accessibilityHeadingDirection(angle: boundedAngle)
        
        if direction == "Left" || direction == "Right" {
            accessibilityAngleDescription = "Destination is \(abs(boundedAngle)) degrees to the \(direction)"
        } else {
            accessibilityAngleDescription = "Destination is \(direction)"
        }
    }
    
    //    func didUpdateDistance(distance: Measurement<UnitLength>) {
    //        self.distanceToDestination = String(distance.value)
    //        self.distanceUnit = distance.unit.symbol
    //    }
    
    //    func didUpdateLocations(locations: [CLLocation]) {
    //        guard let location = locations.last else { return }
    //
    //        self.angleToDestination = calculateAngle(to: destination, from: location)
    //        var distance = location.distance(from: destination)
    //
    //        var unit: UnitLength
    //        if distance <= 500 {
    //            unit = .feet
    //            distanceUnit = "feet"
    //        } else {
    //            unit = .miles
    //            distanceUnit = "miles"
    //        }
    //
    //        distance = Measurement(value: distance, unit: UnitLength.meters).converted(to: unit).value
    //
    //        let myDistance = Measurement(value: distance, unit: UnitLength.miles)
    //        print(myDistance.unit)
    //
    //        let formatter = NumberFormatter()
    //        formatter.numberStyle = .decimal
    //        formatter.maximumFractionDigits = distance > 1 ? 0 : 1
    //
    //        distanceToDestination = formatter.string(from: NSNumber(floatLiteral: distance))!
    //
    //        if distanceToDestination == "1", distanceUnit == "miles" {
    //            distanceUnit = "mile"
    //        }
    //    }
    
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
