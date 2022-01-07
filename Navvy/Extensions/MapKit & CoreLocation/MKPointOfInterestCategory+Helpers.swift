//
//  Category+Image.swift
//  Navigation
//
//  Created by Samuel Shi on 8/8/21.
//

import Foundation
import MapKit

extension MKPointOfInterestCategory {
    func toIcon() -> String {
        switch self {
        case .airport:
            return "airport"
        case .amusementPark:
            #warning("add icon")
            return "default"
        case .aquarium:
            return "aquarium"
        case .atm:
            return "atm"
        case .bakery:
            return "bakery"
        case .bank:
            return "bank"
        case .beach:
            return "beach"
        case .brewery:
            return "brewery"
        case .cafe:
            return "cafe"
        case .campground:
            return "campground"
        case .carRental:
            return "car-rental"
        case .evCharger:
            return "ev-charger"
        case .fireStation:
            return "fire-station"
        case .fitnessCenter:
            return "fitness-center"
        case .foodMarket:
            return "food-market"
        case .gasStation:
            return "gas-station"
        case .hospital:
            return "hospital"
        case .hotel:
            return "hotel"
        case .laundry:
            return "laundry"
        case .library:
            return "library"
        case .marina:
            return "marina"
        case .movieTheater:
            return "movie-theater"
        case .museum:
            return "museum"
        case .nationalPark:
            return "national-park"
        case .nightlife:
            return "nightlife"
        case .park:
            return "park"
        case .parking:
            return "parking"
        case .pharmacy:
            return "pharmacy"
        case .police:
            return "police"
        case .postOffice:
            return "post-office"
        case .publicTransport:
            return "public-transport"
        case .restaurant:
            return "restaurant"
        case .restroom:
            return "restroom"
        case .school:
            return "school"
        case .stadium:
            return "stadium"
        case .store:
            return "store"
        case .theater:
            return "theater"
        case .university:
            return "university"
        case .winery:
            return "winery"
        case .zoo:
            return "zoo"
        default:
            return "default"
        }
    }
    
    var displayName: String {
        switch self {
        case .airport:
            return "Airport"
        case .amusementPark:
            return "Amusement Park"
        case .aquarium:
            return "Aquarium"
        case .atm:
            return "Atm"
        case .bakery:
            return "Bakery"
        case .bank:
            return "Bank"
        case .beach:
            return "Beach"
        case .brewery:
            return "Brewery"
        case .cafe:
            return "Cafe"
        case .campground:
            return "Campground"
        case .carRental:
            return "Car Rental"
        case .evCharger:
            return "EV Charger"
        case .fireStation:
            return "Fire Station"
        case .fitnessCenter:
            return "Fitness Center"
        case .foodMarket:
            return "Food Market"
        case .gasStation:
            return "Gas Station"
        case .hospital:
            return "Hospital"
        case .hotel:
            return "Hotel"
        case .laundry:
            return "Laundry"
        case .library:
            return "Library"
        case .marina:
            return "Marina"
        case .movieTheater:
            return "Movie Theater"
        case .museum:
            return "Museum"
        case .nationalPark:
            return "National Park"
        case .nightlife:
            return "Nightlife"
        case .park:
            return "Park"
        case .parking:
            return "Parking"
        case .pharmacy:
            return "Pharmacy"
        case .police:
            return "Police"
        case .postOffice:
            return "Post Office"
        case .publicTransport:
            return "Public Transport"
        case .restaurant:
            return "Restaurant"
        case .restroom:
            return "Restroom"
        case .school:
            return "School"
        case .stadium:
            return "Stadium"
        case .store:
            return "Store"
        case .theater:
            return "Theater"
        case .university:
            return "University"
        case .winery:
            return "Winery"
        case .zoo:
            return "Zoo"
        default:
            return "Unknown"
        }
    }
}

extension Optional where Wrapped == MKPointOfInterestCategory {
    func toIcon() -> String {
        guard let self = self else { return "default" }
        return self.toIcon()
    }
    
    var displayName: String {
        guard let self = self else { return "Unknown" }
        return self.displayName
    }
}
