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
    func didSelectMapItem(mapItem: MKMapItem)
}

class SearchViewModel: NSObject, ObservableObject {
    @Published var searchTerm: String = ""
    @Published var status: LocationStatus = .noResults

    @Published var autocompleteResults: [MKLocalSearchCompletion] = []
    @Published var detailedMapItems: [MKMapItem] = []
    @Published var region = MKCoordinateRegion()

    var cancellables: [AnyCancellable] = []
    let searchCompleter = MKLocalSearchCompleter()
    var locationManager: LocationManager? = LocationManager()
    var delegate: SearchViewModelDelegate?

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

    func changeAutocompleterRegion(region: MKCoordinateRegion) {
        searchCompleter.region = region
    }

    func selectMapItem(mapItem: MKMapItem) {
        delegate?.didSelectMapItem(mapItem: mapItem)
    }

    func searchNearby(query: String, changeRegion: Bool) {
        status = .searching
        
        LocalSearchPublishers.getMapItems(query: query, region: region)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion, let self = self else { return }
                self.status = .error(error.localizedDescription)
            } receiveValue: { [weak self] mapItems in
                self?.detailedMapItems = mapItems
                self?.status = .hasResults
                self?.delegate?.changeSearchBarText(newText: query)

                let coordinates = mapItems.map(\.placemark.coordinate)

                if changeRegion, let region = MKCoordinateRegion(containing: coordinates) {
                    self?.region = region
                }
            }
            .store(in: &cancellables)
    }

    func fetchAndSelectMapItem(forCompletion completion: MKLocalSearchCompletion) {
        status = .searching
        
        LocalSearchPublishers.getMapItems(completion: completion, region: region)
            .map(\.first)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion, let self = self else { return }
                self.status = .error(error.localizedDescription)
            } receiveValue: { [weak self] mapItem in
                guard let mapItem = mapItem, let self = self else { return }
                self.detailedMapItems = [mapItem]
                self.selectMapItem(mapItem: mapItem)
            }
            .store(in: &cancellables)
    }

    func fetchMapItems(forCompletions completions: [MKLocalSearchCompletion]) {
        guard !completions.isEmpty else {
            status = .error("Cannot search with empty autocomplete suggestions")
            return
        }

        status = .searching
        LocalSearchPublishers.getMapItems(completions: completions, region: region)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion, let self = self else { return }
                self.status = .error(error.localizedDescription)
            } receiveValue: { [weak self] mapItems in
                self?.detailedMapItems = mapItems
                self?.status = mapItems.isEmpty ? .noResults : .hasResults
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
