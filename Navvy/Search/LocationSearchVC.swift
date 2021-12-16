//
//  LocationSearchVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import Combine
import UIKit
import MapKit

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
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    lazy var detailedSearchVC: DetailedSearchVC = {
        let detailedSearchVC = DetailedSearchVC()
        detailedSearchVC.searchViewModel = searchViewModel
        detailedSearchVC.view.translatesAutoresizingMaskIntoConstraints = false
        return detailedSearchVC
    }()
    
    lazy var searchViewModel: SearchViewModel = {
        let vm = SearchViewModel()
        vm.delegate = self
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        addChildViewController(child: detailedSearchVC)
        
        NSLayoutConstraint.activate([
            detailedSearchVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailedSearchVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            detailedSearchVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            detailedSearchVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parent?.navigationItem.searchController = searchController
        searchController.searchBar.becomeFirstResponder()
    }
}

extension LocationSearchVC: SearchViewModelDelegate {
    func didSelectMapItem(mapItem: MKMapItem) {
        detailedSearchVC.setMapRegion(region: MKCoordinateRegion(center: mapItem.placemark.coordinate, radius: 0.025))
        autocompleteVC.dismiss(animated: true)
        
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBlue
        
        if let presentationController = vc.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
                
        present(vc, animated: true)
    }
    
    func changeSearchBarText(newText: String) {
        searchController.searchBar.text = newText
    }
}

extension LocationSearchVC: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
}

extension LocationSearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        searchViewModel.searchTerm = text
    }
}

extension LocationSearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty, !searchViewModel.autocompleteResults.isEmpty else { return }
        searchViewModel.searchNearby(query: text, changeRegion: true)
        autocompleteVC.dismiss(animated: true)
    }
}
