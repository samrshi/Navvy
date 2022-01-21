//
//  LocationService.swift
//  Weather
//
//  Created by Samuel Shi on 5/25/2021.
//

import Combine
import Foundation
import MapKit

class SearchViewModel: NSObject, ObservableObject {
    @Published var searchTerm: String = ""
    @Published var status: LocationStatus = .noResults

    @Published var autocompleteResults: [MKLocalSearchCompletion] = []
    @Published var destinations: [Destination] = []
    @Published var region = MKCoordinateRegion()

    var cancellables: [AnyCancellable] = []
    let searchCompleter = MKLocalSearchCompleter()
    var locationManager: LocationManager? = LocationManager()

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest, .query]
        setUpObservers()
    }

    func setUpObservers() {
        $searchTerm
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main, options: nil)
            .sink { searchTerm in
                self.status = .searching
                self.searchCompleter.queryFragment = searchTerm

                if searchTerm.isEmpty {
                    self.status = .noResults
                    self.autocompleteResults = []
                    self.destinations = []

                    if let userLocation = LocationManager.shared.userLocation {
                        self.region = MKCoordinateRegion(center: userLocation, radius: 0.1)
                    }
                }
            }
            .store(in: &cancellables)

        locationManager?.$locations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                guard let coordinate = locations.first?.coordinate else { return }

                self?.region = MKCoordinateRegion(center: coordinate, radius: 0.1)
                self?.locationManager = nil
            }
            .store(in: &cancellables)

        $region
            .weaklyAssign(to: \.searchCompleter.region, on: self)
            .store(in: &cancellables)
    }

    func changeAutocompleterRegion(region: MKCoordinateRegion) {
        searchCompleter.region = region
    }

    func searchNearby(query: String = "", categoryFilter: [MKPointOfInterestCategory] = [], changeRegion: Bool) {
        status = .searching

        LocalSearchPublishers.getDestinations(query: query, region: region, categoryFilter: categoryFilter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion, let self = self else { return }
                self.status = .error(error.localizedDescription)
            } receiveValue: { [weak self] destinations in
                self?.destinations = destinations
                self?.status = .hasResults

                let coordinates = destinations.map(\.coordinates)
                if changeRegion, let region = MKCoordinateRegion(containing: coordinates) {
                    self?.region = region
                }
            }
            .store(in: &cancellables)
    }

    func fetchDestination(forSearchCompletion searchCompletion: MKLocalSearchCompletion,
                          completion: @escaping (Result<Destination, Error>) -> Void)
    {
        status = .searching

        LocalSearchPublishers.getDestination(forCompletion: searchCompletion, region: region)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] publisherCompletion in
                guard case .failure(let error) = publisherCompletion, let self = self else { return }
                self.status = .error(error.localizedDescription)
                completion(.failure(error))
            } receiveValue: { [weak self] destination in
                guard let self = self else { return }
                self.destinations = [destination]
                completion(.success(destination))
            }
            .store(in: &cancellables)
    }
}

extension SearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        autocompleteResults = completer.results
        status = completer.results.isEmpty ? .noResults : .hasResults
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        guard !completer.queryFragment.isEmpty else { return }
        status = .error(error.localizedDescription)
    }
}

extension SearchViewModel {
    enum LocationStatus: Equatable {
        case noResults
        case searching
        case error(String)
        case hasResults

        var displayString: String {
            switch self {
            case .noResults:
                return "No search results yet..."
            case .searching:
                return "Searching..."
            case .error(let message):
                return message
            case .hasResults:
                return "Received search results"
            }
        }
    }
}
