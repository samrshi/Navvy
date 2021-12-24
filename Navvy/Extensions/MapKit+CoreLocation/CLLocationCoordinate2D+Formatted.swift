//
//  CLLocationCoordinate2D+Formatted.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import CoreLocation

extension CLLocationCoordinate2D {
    var formatted: String {
        let lat = "\(abs(latitude))º \(latitude >= 0 ? "N" : "S")"
        let lon = "\(abs(longitude))º \(longitude >= 0 ? "E" : "W")"
        return "\(lat), \(lon)"
    }
}
