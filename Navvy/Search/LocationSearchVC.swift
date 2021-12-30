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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
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
        return SearchViewModel()
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
        addChildViewController(child: detailedSearchVC, toView: scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            detailedSearchVC.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            detailedSearchVC.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            detailedSearchVC.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            detailedSearchVC.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ])
        
        let contentViewCenterY = detailedSearchVC.view.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        contentViewCenterY.priority = .defaultLow

        let contentViewHeight = detailedSearchVC.view.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow

        NSLayoutConstraint.activate([
            detailedSearchVC.view.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentViewCenterY,
            contentViewHeight
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.searchController = searchController
    }
}

extension LocationSearchVC: DetailedSearchVCDelegate, AutocompleteResultsVCDelegate {
    func didSelectLocationFromTableView() {
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    func didSelectSearchResult(result: NavigationViewModel) {
        
        let userLocation = detailedSearchVC.mapVC.mapView.userLocation.coordinate
        if var region = MKCoordinateRegion(containing: [result.destinationCoordinates, userLocation]) {
            #warning("come back to this and see if i still like it later")
            if region.span.longitudeDelta > 100 {
                region = MKCoordinateRegion(center: result.destinationCoordinates, radius: 10)
            }
            detailedSearchVC.mapVC.setMapRegion(region: region)
        }
        
        autocompleteVC.dismiss(animated: true)
        
        let vc = DestinationConfirmationVC()
        vc.setUp(vm: result)
        
        if let presentationController = vc.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
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
        changeSearchBarText(newText: text)
        autocompleteVC.dismiss(animated: true)
    }
}
