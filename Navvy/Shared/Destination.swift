//
//  Destination.swift
//  Navvy
//
//  Created by Samuel Shi on 1/6/22.
//

import CoreLocation
import Foundation
import MapKit

struct Destination: Identifiable {
    let id: UUID
    
    let name: String?
    let category: MKPointOfInterestCategory?
    let coordinates: CLLocationCoordinate2D

    let url: URL?
    let address: String?
    let phoneNumber: String?
}

extension Destination {
    init(mapItem: MKMapItem) {
        id = UUID()
        
        name = mapItem.name
        category = mapItem.pointOfInterestCategory
        coordinates = mapItem.placemark.coordinate
        
        url = mapItem.url
        address = mapItem.placemark.title
        phoneNumber = mapItem.phoneNumber
    }
}
