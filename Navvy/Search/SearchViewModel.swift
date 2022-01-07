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
    @Published var detailedMapItems: [MKMapItem] = []
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

                if !searchTerm.isEmpty {
                    self.searchCompleter.queryFragment = searchTerm
                } else {
                    self.status = .noResults
                    self.autocompleteResults = []
                    self.detailedMapItems = []
                }
            }
            .store(in: &cancellables)

        locationManager?.locationsPublisher
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

        LocalSearchPublishers.getMapItems(query: query, region: region, categoryFilter: categoryFilter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion, let self = self else { return }
                self.status = .error(error.localizedDescription)
            } receiveValue: { [weak self] mapItems in
                self?.detailedMapItems = mapItems
                self?.status = .hasResults

                let coordinates = mapItems.map(\.placemark.coordinate)
                if changeRegion, let region = MKCoordinateRegion(containing: coordinates) {
                    self?.region = region
                }
            }
            .store(in: &cancellables)
    }

    func fetchMapItem(forSearchCompletion searchCompletion: MKLocalSearchCompletion, completion: @escaping (Result<MKMapItem, Error>) -> Void) {
        status = .searching

        LocalSearchPublishers.getMapItems(completion: searchCompletion, region: region)
            .map(\.first)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] publisherCompletion in
                guard case .failure(let error) = publisherCompletion, let self = self else { return }
                self.status = .error(error.localizedDescription)
                completion(.failure(error))
            } receiveValue: { [weak self] mapItem in
                guard let mapItem = mapItem, let self = self else { return }
                self.detailedMapItems = [mapItem]
                completion(.success(mapItem))
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
