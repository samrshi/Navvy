//
//  Destination.swift
//  Navvy
//
//  Created by Samuel Shi on 1/6/22.
//

import CoreLocation
import Foundation
import MapKit

struct Destination: Identifiable, Hashable {
    let id: UUID
    
    let name: String?
    let category: MKPointOfInterestCategory?
    let latitude: Double
    let longitude: Double

    let url: URL?
    let address: String?
    let phoneNumber: String?
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Destination: Equatable {
    static func == (lhs: Destination, rhs: Destination) -> Bool {
        lhs.id == rhs.id
    }
}

extension Destination {
    init(mapItem: MKMapItem) {
        id = UUID()
        
        name = mapItem.name
        category = mapItem.pointOfInterestCategory
        
        latitude = mapItem.placemark.coordinate.latitude
        longitude = mapItem.placemark.coordinate.longitude
        
        url = mapItem.url
        address = mapItem.placemark.title
        phoneNumber = mapItem.phoneNumber
    }
}
