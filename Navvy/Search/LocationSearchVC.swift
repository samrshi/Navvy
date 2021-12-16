//
//  LocationSearchVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import UIKit
import Combine

class LocationSearchVC: UIViewController {
    var cancellables = [AnyCancellable]()
    
    lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, World"
        return label
    }()
    
    lazy var autocompleteVC: AutocompleteResultsVC = {
        let autocompleteResultsVC = AutocompleteResultsVC()
        autocompleteResultsVC.searchViewModel = searchViewModel
        return autocompleteResultsVC
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: autocompleteVC)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    lazy var detailedSearchVC: DetailedSearchVC = {
        let detailedSearchVC = DetailedSearchVC()
        detailedSearchVC.searchViewModel = searchViewModel
        return detailedSearchVC
    }()
    
    let searchViewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchViewModel.delegate = self
        
        detailedSearchVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailedSearchVC.view)
        addChild(detailedSearchVC)
        detailedSearchVC.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            detailedSearchVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailedSearchVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            detailedSearchVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            detailedSearchVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parent?.navigationItem.searchController = searchController
    }
}

extension LocationSearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        searchViewModel.queryFragment = text
    }
}

extension LocationSearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // search nearby
    }
}

extension LocationSearchVC: SearchViewModelDelegate {
    func changeSearchBarText(newText: String) {
        searchController.searchBar.text = newText
    }
}
