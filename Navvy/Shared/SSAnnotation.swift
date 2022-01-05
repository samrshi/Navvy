//
//  SSAnnotation.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import MapKit

class SSAnnotation: NSObject, MKAnnotation {
    var mapItem: MKMapItem

    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }

    var title: String? {
        mapItem.name
    }

    var coordinate: CLLocationCoordinate2D {
        mapItem.placemark.coordinate
    }
}
