//
//  SSAnnotation.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import MapKit

class SSAnnotation: NSObject, MKAnnotation {
    var destination: Destination

    init(destination: Destination) {
        self.destination = destination
    }

    var title: String? {
        destination.name
    }

    var coordinate: CLLocationCoordinate2D {
        destination.coordinates
    }
}
