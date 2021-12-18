//
//  DetailedSearchVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import Combine
import MapKit
import UIKit

class DetailedSearchVC: UIViewController {
    var searchViewModel: SearchViewModel!
    var detailedSearchResults = [NavigationViewModel]()
    
    var cancellables = [AnyCancellable]()
    var nextRegionChangeIsFromUserInteraction = false

    lazy var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.layer.cornerRadius = 10
        mapView.clipsToBounds = true
        mapView.delegate = self
        return mapView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DetailedSearchTableViewCell.self, forCellReuseIdentifier: DetailedSearchTableViewCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    lazy var searchAgainButton: UIButton = {
        let searchAgainButton = UIButton(frame: .zero)
        searchAgainButton.translatesAutoresizingMaskIntoConstraints = false
        searchAgainButton.setTitle("Search This Area", for: .normal)
        searchAgainButton.addAction(UIAction(handler: searchThisArea), for: .touchUpInside)
        searchAgainButton.tintColor = .systemBlue.withAlphaComponent(0.5)
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Search This Area"
        configuration.image = UIImage(systemName: "arrow.counterclockwise")
        configuration.imagePadding = 5
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .mini
        searchAgainButton.configuration = configuration

        return searchAgainButton
    }()
    
    var searchButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        view.addSubview(tableView)
        mapView.addSubview(searchAgainButton)

        searchButtonBottomConstraint = searchAgainButton.bottomAnchor.constraint(equalTo: mapView.topAnchor)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 2/3),
            
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            searchAgainButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            searchButtonBottomConstraint
        ])
        
        searchViewModel.$detailedMapItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mapItems in
                self?.detailedSearchResults = mapItems.map(NavigationViewModel.init)
                self?.tableView.reloadData()
                self?.updateMapItems(mapItems: mapItems)
                
                self?.toggleSearchButton(shouldShow: false)
            }
            .store(in: &cancellables)
        
        searchViewModel.$region
            .receive(on: DispatchQueue.main)
            .sink { [weak self] region in
                self?.setMapRegion(region: region)
            }
            .store(in: &cancellables)
    }
    
    func toggleSearchButton(shouldShow: Bool) {
        guard shouldShow == (searchButtonBottomConstraint.constant == 0),
              !searchViewModel.searchTerm.isEmpty
        else {
            return
        }
        
        let showConstant = searchAgainButton.frame.size.height + 5
        searchButtonBottomConstraint?.constant = shouldShow ? showConstant : 0
        
        UIView.animate(withDuration: 0.25) {
            self.mapView.layoutSubviews()
        }
    }
    
    func searchThisArea(_: UIAction) {
        searchViewModel.searchNearby(query: searchViewModel.searchTerm, changeRegion: false)
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
        let mapItem = detailedSearchResults[indexPath.row].mapItem
        searchViewModel.selectMapItem(mapItem: mapItem)
        
        if let annotation = mapView.annotations.first(where: {
            ($0 as? SSAnnotation)?.mapItem == mapItem
        }) {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

extension DetailedSearchVC: MKMapViewDelegate {
    func updateMapItems(mapItems: [MKMapItem]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(mapItems.map(SSAnnotation.init))
    }
    
    func setMapRegion(region: MKCoordinateRegion) {
        UIView.animate(withDuration: 0.25) {
            self.mapView.region = region
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = (view.annotation as? SSAnnotation) else { return }
        searchViewModel.selectMapItem(mapItem: annotation.mapItem)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        guard let view = mapView.subviews.first,
              let recognizers = view.gestureRecognizers else { return }
        
        for recognizer in recognizers {
            if recognizer.state == .began || recognizer.state == .ended {
                nextRegionChangeIsFromUserInteraction = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if nextRegionChangeIsFromUserInteraction {
            nextRegionChangeIsFromUserInteraction = false
            toggleSearchButton(shouldShow: true)
            searchViewModel.region = mapView.region
        }
    }
}
