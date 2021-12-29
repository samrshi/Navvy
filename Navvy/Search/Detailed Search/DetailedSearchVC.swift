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
    func didSelectLocationFromTableView()
    func didSelectSearchResult(result: NavigationViewModel)
    func changeSearchBarText(newText: String)
}

class DetailedSearchVC: UIViewController {
    var searchViewModel: SearchViewModel!
    var detailedSearchResults = [NavigationViewModel]()
    weak var delegate: DetailedSearchVCDelegate?
    
    var cancellables = [AnyCancellable]()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DetailedSearchTableViewCell.self, forCellReuseIdentifier: DetailedSearchTableViewCell.reuseId)
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    lazy var mapVC: MapVC = {
        let mapVC = MapVC()
        mapVC.delegate = self
        mapVC.view.translatesAutoresizingMaskIntoConstraints = false
        return mapVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        addChildViewController(child: mapVC)
        
        NSLayoutConstraint.activate([
            mapVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            mapVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: mapVC.view.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        searchViewModel.$detailedMapItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mapItems in
                self?.didReceiveResults(results: mapItems)
            }
            .store(in: &cancellables)
        
        searchViewModel.$region
            .receive(on: DispatchQueue.main)
            .sink { [weak self] region in
                self?.mapVC.setMapRegion(region: region)
            }
            .store(in: &cancellables)
    }
    
    func didReceiveResults(results: [MKMapItem]) {
        detailedSearchResults = results.map(NavigationViewModel.init)
        tableView.reloadData()
        mapVC.updateMapItems(mapItems: results)
        
        mapVC.toggleSearchButton(shouldShow: false)
    }
}

extension DetailedSearchVC: MapVCDelegate {
    func searchCurrentArea() {
        searchViewModel.searchNearby(query: searchViewModel.searchTerm, changeRegion: false)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailedSearchTableViewCell.reuseId) as? DetailedSearchTableViewCell else {
            return UITableViewCell()
        }
        
        let result = detailedSearchResults[indexPath.row]
        cell.setUp(navigationVM: result)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailedSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Search Results"
    }
}

extension DetailedSearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = detailedSearchResults[indexPath.row]
        mapVC.selectAnnotation(forMapItem: result.mapItem)
        delegate?.didSelectSearchResult(result: result)
        delegate?.didSelectLocationFromTableView()
    }
}
