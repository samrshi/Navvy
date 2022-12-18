//
//  MapVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/22/21.
//

import MapKit
import UIKit

protocol SearchMapViewDelegate: AnyObject {
    func searchMapViewSearchCurrentArea()
    func searchMapViewShouldShowSearchAgainButton() -> Bool
    func searchMapViewDidSelectDestination(destination: Destination)
    func searchMapViewMapRegionDidChange(region: MKCoordinateRegion)
}

class SearchMapView: UIView {
    lazy var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.layer.cornerRadius = 10
        mapView.clipsToBounds = true
        mapView.delegate = self
        return mapView
    }()
    
    lazy var searchAgainButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        button.addAction(UIAction(handler: searchThisArea), for: .touchUpInside)
        button.accessibilityHint = "Search New Map Area"
        button.tintColor = .label
        return button
    }()
    
    lazy var showUserLocationButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.addAction(UIAction(handler: showUserRegion), for: .touchUpInside)
        button.tintColor = .label
        return button
    }()
    
    var nextRegionChangeIsFromUserInteraction = false
    var viewHeightConstraint: NSLayoutConstraint!
    var searchButtonBottomConstraint: NSLayoutConstraint!
    weak var delegate: SearchMapViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(mapView)
        mapView.addSubview(searchAgainButton)
        mapView.addSubview(showUserLocationButton)

        searchButtonBottomConstraint = searchAgainButton.bottomAnchor.constraint(equalTo: mapView.topAnchor)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            heightAnchor.constraint(equalToConstant: 230),
            
            showUserLocationButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 5),
            showUserLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -5),
            showUserLocationButton.widthAnchor.constraint(equalTo: showUserLocationButton.heightAnchor),
            showUserLocationButton.heightAnchor.constraint(equalToConstant: 30),
            
            searchAgainButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 5),
            searchAgainButton.widthAnchor.constraint(equalTo: searchAgainButton.heightAnchor),
            searchAgainButton.heightAnchor.constraint(equalToConstant: 30),
            searchButtonBottomConstraint
        ])
    }
    
    func searchThisArea(_: UIAction) {
        delegate.searchMapViewSearchCurrentArea()
    }
    
    func showUserRegion(_: UIAction) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, radius: 0.1)
        setMapRegion(region: region)
    }
    
    func selectAnnotation(forDestination destination: Destination) {
        guard let annotation = mapView.annotations
            .compactMap({ $0 as? SSAnnotation })
            .first(where: { $0.destination == destination })
        else {
            return
        }
        
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    func deselectAnnotations() {
        mapView.selectedAnnotations.forEach {
            mapView.deselectAnnotation($0, animated: true)
        }
    }
    
    func updateAnnotations(destinations: [Destination]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(destinations.map(SSAnnotation.init))
    }
    
    func setMapRegion(region: MKCoordinateRegion) {
        UIView.animate(withDuration: 0.25) {
            self.mapView.region = region
        }
    }
    
    func toggleSearchButton(shouldShow: Bool) {
        guard shouldShow == (searchButtonBottomConstraint.constant == 0) else { return }
        guard delegate.searchMapViewShouldShowSearchAgainButton() else { return }
        
        let showConstant = searchAgainButton.frame.size.height + 5
        searchButtonBottomConstraint?.constant = shouldShow ? showConstant : 0
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.mapView.layoutSubviews()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = (view.annotation as? SSAnnotation) else { return }
        
        delegate.searchMapViewDidSelectDestination(destination: annotation.destination)
        
        DispatchQueue.main.async { [weak self] in
            self?.nextRegionChangeIsFromUserInteraction = false
        }
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
            delegate.searchMapViewMapRegionDidChange(region: mapView.region)
        }
    }
}
