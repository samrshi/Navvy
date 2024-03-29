//
//  DetailedSearchVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import Combine
import MapKit
import UIKit

protocol DetailedSearchVCDelegate: AnyObject {
    func didSelectSearchResult(result: NavigationViewModel)
    func changeSearchBarText(newText: String)
}

class DetailedSearchVC: UIViewController {
    var cancellables = [AnyCancellable]()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DestinationTableViewCell.self, forCellReuseIdentifier: DestinationTableViewCell.reuseId)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    lazy var mapTableViewCell: SearchMapTableViewCell = {
        let cell = SearchMapTableViewCell(style: .default, reuseIdentifier: SearchMapTableViewCell.reuseId)
        cell.setUp(delegate: self)
        return cell
    }()
    
    lazy var quickSearchTableViewCell: QuickSearchTableViewCell = {
        let cell = QuickSearchTableViewCell(didSelectCategory: quickSearchDidSelectCategory)
        return cell
    }()
    
    var searchViewModel: SearchViewModel!
    var detailedSearchResults: [NavigationViewModel] = []
    weak var delegate: DetailedSearchVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addAndPinSubview(tableView)
    }
    
    func setUp() {
        searchViewModel.$destinations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] destinations in
                self?.didReceiveResults(destinations: destinations)
            }
            .store(in: &cancellables)
        
        searchViewModel.$region
            .receive(on: DispatchQueue.main)
            .sink { [weak self] region in
                self?.mapTableViewCell.mapView.setMapRegion(region: region)
            }
            .store(in: &cancellables)
    }
    
    func didReceiveResults(destinations: [Destination]) {
        detailedSearchResults = destinations.map(NavigationViewModel.init)
        tableView.reloadData()
        
        mapTableViewCell.mapView.updateAnnotations(destinations: destinations)
        mapTableViewCell.mapView.toggleSearchButton(shouldShow: false)
    }
    
    func quickSearchDidSelectCategory(category: MKPointOfInterestCategory) {
        searchViewModel.searchNearby(query: category.displayName, changeRegion: true)
        delegate?.changeSearchBarText(newText: category.displayName)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

extension DetailedSearchVC: SearchMapViewDelegate {
    func searchMapViewSearchCurrentArea() {
        searchViewModel.searchNearby(query: searchViewModel.searchTerm, changeRegion: true)
        delegate?.changeSearchBarText(newText: searchViewModel.searchTerm)
    }
    
    func searchMapViewShouldShowSearchAgainButton() -> Bool {
        !searchViewModel.searchTerm.isEmpty
    }
    
    func searchMapViewDidSelectDestination(destination: Destination) {
        delegate?.didSelectSearchResult(result: NavigationViewModel(destination: destination))
    }
    
    func searchMapViewMapRegionDidChange(region: MKCoordinateRegion) {
        searchViewModel.region = region
    }
}

extension DetailedSearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return mapTableViewCell
        }
        
        guard !detailedSearchResults.isEmpty else {
            return quickSearchTableViewCell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DestinationTableViewCell.reuseId) as? DestinationTableViewCell else {
            return UITableViewCell()
        }
        
        let result = detailedSearchResults[indexPath.row]
        cell.setUp(navigationVM: result, showCustomSeparator: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1, detailedSearchResults.isEmpty {
            return 1
        } else {
            return detailedSearchResults.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else if section == 1, detailedSearchResults.isEmpty {
            return "Quick Search"
        } else {
            return "Search Results"
        }
    }
}

extension DetailedSearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        } else if indexPath.section == 1, detailedSearchResults.isEmpty {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = detailedSearchResults[indexPath.row]
        delegate?.didSelectSearchResult(result: result)
        mapTableViewCell.mapView.selectAnnotation(forDestination: result.destination)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
