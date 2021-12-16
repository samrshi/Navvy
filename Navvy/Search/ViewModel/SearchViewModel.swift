//
//  LocationService.swift
//  Weather
//
//  Created by Samuel Shi on 5/25/2021.
//

import Combine
import Foundation
import MapKit

protocol SearchViewModelDelegate: AnyObject {
    func changeSearchBarText(newText: String)
}

class SearchViewModel: NSObject, ObservableObject {
    enum LocationStatus: Equatable {
        case idle
        case noResults
        case isSearching
        case error(String)
        case result
    }

    @Published var status: LocationStatus = .idle

    // Autcomplete
    @Published var queryFragment: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []

    // Detailed Search
    @Published var mapItems: [MKMapItem] = []
    @Published var region = MKCoordinateRegion()

    let searchCompleter = MKLocalSearchCompleter()
    var locationManager: LocationManager? = LocationManager()

    var cancellables: [AnyCancellable] = []
    var delegate: SearchViewModelDelegate?
    
    override init() {
        super.init()

        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest, .query]
        setUpObservers()
    }

    func setUpObservers() {
        $queryFragment
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main, options: nil)
            .sink { fragment in
                self.status = .isSearching
                if !fragment.isEmpty {
                    self.searchCompleter.queryFragment = fragment
                } else {
                    self.status = .idle
                    self.searchResults = []
                }
            }
            .store(in: &cancellables)

        locationManager?.locationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { locations in
                guard let coordinate = locations.first?.coordinate else { return }

                self.region = MKCoordinateRegion(center: coordinate, radius: 0.1)
                self.locationManager = nil
            }
            .store(in: &cancellables)

        $region
            .sink { region in
                self.searchCompleter.region = region
            }
            .store(in: &cancellables)
    }

    func searchNearby(query: String, changeRegion: Bool) {
        status = .isSearching

        LocalSearchPublishers.geocode(query: query, region: region)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.status = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] mapItems in
                self?.mapItems = mapItems
                self?.status = .result
                self?.delegate?.changeSearchBarText(newText: query)
                
                let coordinates = mapItems.map(\.placemark.coordinate)

                if changeRegion, let region = MKCoordinateRegion(containing: coordinates) {
                    self?.region = region
                }
            }
            .store(in: &cancellables)
    }

    func fetchMapItem(completion: MKLocalSearchCompletion) {
        LocalSearchPublishers.geocode(completionResult: completion, region: nil)
            .map(\.first)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.status = .error(error.localizedDescription)
                }
            } receiveValue: { _ in
                #warning("Did select map item")
            }
            .store(in: &cancellables)
    }

    func changeAutocompleterRegion(region: MKCoordinateRegion) {
        searchCompleter.region = region
    }
}

extension SearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        status = completer.results.isEmpty ? .noResults : .result
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        status = .error(error.localizedDescription)
    }
}
