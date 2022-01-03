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
        tableView.register(DetailedSearchTableViewCell.self, forCellReuseIdentifier: DetailedSearchTableViewCell.reuseId)
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
    
    var searchViewModel: SearchViewModel!
    var detailedSearchResults: [NavigationViewModel] = []
    weak var delegate: DetailedSearchVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addAndPinSubview(tableView)
        
        searchViewModel.$detailedMapItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mapItems in
                self?.didReceiveResults(results: mapItems)
            }
            .store(in: &cancellables)
        
        searchViewModel.$region
            .receive(on: DispatchQueue.main)
            .sink { [weak self] region in
                self?.mapTableViewCell.mapView.setMapRegion(region: region)
            }
            .store(in: &cancellables)
    }
    
    func didReceiveResults(results: [MKMapItem]) {
        detailedSearchResults = results.map(NavigationViewModel.init)
        tableView.reloadData()
        
        mapTableViewCell.mapView.updateMapItems(mapItems: results)
        mapTableViewCell.mapView.toggleSearchButton(shouldShow: false)
    }
}

extension DetailedSearchVC: SearchMapViewDelegate {
    func searchCurrentArea() {
        searchViewModel.searchNearby(query: searchViewModel.searchTerm, changeRegion: true)
        delegate?.changeSearchBarText(newText: searchViewModel.searchTerm)
    }
    
    func shouldShowSearchAgainButton() -> Bool {
        !searchViewModel.searchTerm.isEmpty
    }
    
    func didSelectMapItem(mapItem: MKMapItem) {
        delegate?.didSelectSearchResult(result: NavigationViewModel(mapItem: mapItem))
    }
    
    func mapRegionDidChange(region: MKCoordinateRegion) {
        searchViewModel.region = region
    }
}

extension DetailedSearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return mapTableViewCell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailedSearchTableViewCell.reuseId) as? DetailedSearchTableViewCell else {
            return UITableViewCell()
        }
        
        let result = detailedSearchResults[indexPath.row]
        cell.setUp(navigationVM: result)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return detailedSearchResults.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Search Results" : nil
    }
}

extension DetailedSearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section != 0 ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = detailedSearchResults[indexPath.row]
        mapTableViewCell.mapView.selectAnnotation(forMapItem: result.mapItem)
        delegate?.didSelectSearchResult(result: result)
    }
}
