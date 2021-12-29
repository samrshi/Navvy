//
//  CLLocationCoordinate2D+Formatted.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import CoreLocation

extension CLLocationCoordinate2D {
    var formatted: String {
        var latitudeString = abs(latitude).formatted(.number.precision(.fractionLength(4)))
        var longitudeString = abs(longitude).formatted(.number.precision(.fractionLength(4)))

        latitudeString = "\(latitudeString)º \(latitude >= 0 ? "N" : "S")"
        longitudeString = "\(longitudeString)º \(longitude >= 0 ? "E" : "W")"
        
        return "\(latitudeString), \(longitudeString)"
    }
}
