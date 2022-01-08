//
//  LocationSearchVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import Combine
import MapKit
import UIKit

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
        autocompleteResultsVC.delegate = self
        autocompleteResultsVC.searchViewModel = searchViewModel
        return autocompleteResultsVC
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: autocompleteVC)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a destination"
        return searchController
    }()
    
    lazy var detailedSearchVC: DetailedSearchVC = {
        let detailedSearchVC = DetailedSearchVC()
        detailedSearchVC.delegate = self
        detailedSearchVC.searchViewModel = searchViewModel
        detailedSearchVC.view.translatesAutoresizingMaskIntoConstraints = false
        return detailedSearchVC
    }()
    
    lazy var searchViewModel: SearchViewModel = {
        SearchViewModel()
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primaryBackground
        
        view.addSubview(scrollView)
        addChildViewController(child: detailedSearchVC, toView: view)
        
        NSLayoutConstraint.activate([
            detailedSearchVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailedSearchVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            detailedSearchVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            detailedSearchVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        let contentViewCenterY = detailedSearchVC.view.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        contentViewCenterY.priority = .defaultLow

        let contentViewHeight = detailedSearchVC.view.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow

        NSLayoutConstraint.activate([
            detailedSearchVC.view.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentViewCenterY,
            contentViewHeight,
        ])
        
        searchViewModel.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .error(let error):
                    self?.showToastError(title: "An Error Occurred", message: error)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.searchController = searchController
    }
    
    func clearSearchResults() {
        searchViewModel.destinations = []
        searchViewModel.autocompleteResults = []
        searchController.searchBar.text = ""
    }
}

extension LocationSearchVC: DetailedSearchVCDelegate, AutocompleteResultsVCDelegate {
    func didSelectSearchResult(result: NavigationViewModel) {
        // Show Confirmation View Controller Modally
        if presentedViewController == nil {
            startNavigation(navigationVM: result)
        }
        
        // Select Matching MapView Annotation and Change Region
        detailedSearchVC.mapTableViewCell.mapView.selectAnnotation(forDestination: result.destination)
        
        let region = MKCoordinateRegion(center: result.destinationCoordinates, radius: 0.1)
        detailedSearchVC.mapTableViewCell.mapView.setMapRegion(region: region)
            
        // Dismiss Search Controller Results VC
        autocompleteVC.dismiss(animated: true)
    }
    
    func changeSearchBarText(newText: String) {
        searchController.searchBar.text = newText
    }
}

extension LocationSearchVC: DestinationConfirmationVCDelegate {
    func didDismissDestinationConfirmation() {
        detailedSearchVC.mapTableViewCell.mapView.deselectAnnotations()
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
        changeSearchBarText(newText: text)
        autocompleteVC.dismiss(animated: true)
    }
}
