//
//  LocalSearchPublishers.swift
//  Navigation
//
//  Created by Samuel Shi on 8/9/21.
//

import Combine
import Foundation
import MapKit

enum LocalSearchPublishers {
    static func localSearch(request: MKLocalSearch.Request,
                            completion: @escaping (Result<[MKMapItem], Error>) -> Void) {
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            if let error = error {
                completion(.failure(error))
            }

            if let mapItems = response?.mapItems {
                completion(.success(mapItems))
            } else {
                completion(.success([]))
            }
        }
    }

    static func getDestinations(query: String?,
                                region: MKCoordinateRegion,
                                categoryFilter: [MKPointOfInterestCategory] = []) -> AnyPublisher<[Destination], Error> {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region

        return Future { promise in
            localSearch(request: request, completion: promise)
        }
        .map { $0.map(Destination.init) }
        .eraseToAnyPublisher()
    }

    static func getDestination(forCompletion completion: MKLocalSearchCompletion,
                               region: MKCoordinateRegion) -> AnyPublisher<Destination, Error> {
        let request = MKLocalSearch.Request(completion: completion)
        request.region = region

        return Future { promise in
            localSearch(request: request, completion: promise)
        }
        .compactMap(\.first)
        .map { Destination(mapItem: $0) }
        .eraseToAnyPublisher()
    }
}
