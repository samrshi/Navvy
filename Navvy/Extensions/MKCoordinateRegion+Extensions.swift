//
//  MKCoordinateRegion+Extensions.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import MapKit

extension MKCoordinateRegion {
    init(center: CLLocationCoordinate2D, radius: Double) {
        let span = MKCoordinateSpan(latitudeDelta: radius, longitudeDelta: radius)
        self.init(center: center, span: span)
    }

    init?(containing coordinates: [CLLocationCoordinate2D]) {
        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)

        guard let minimumLatitude = latitudes.min(),
              let minimumLongitude = longitudes.min(),
              let maximumLatitude = latitudes.max(),
              let maximumLongitude = longitudes.max() else { return nil }

        let centerLatitude = (minimumLatitude + maximumLatitude) / 2
        let centerLongitude = (minimumLongitude + maximumLongitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)

        let latitudeDelta = maximumLatitude - minimumLatitude
        let longitudeDelta = minimumLongitude - minimumLongitude
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)

        self.init(center: center, span: span)
    }
}
