//
//  MapVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/22/21.
//

import MapKit
import UIKit

protocol MapVCDelegate: AnyObject {
    func searchCurrentArea()
    func shouldShowSearchAgainButton() -> Bool
    func didSelectMapItem(mapItem: MKMapItem)
    func mapRegionDidChange(region: MKCoordinateRegion)
}

class MapVC: UIViewController {
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
    
    lazy var mapSizeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        button.addAction(UIAction(handler: toggleMapViewHeight), for: .touchUpInside)
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
    weak var delegate: MapVCDelegate!

    let mapViewSmallAspectRatio: Double = 2/3
    let mapViewBigAspectRatio: Double = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        mapView.addSubview(searchAgainButton)
        mapView.addSubview(mapSizeButton)
        mapView.addSubview(showUserLocationButton)

        searchButtonBottomConstraint = searchAgainButton.bottomAnchor.constraint(equalTo: mapView.topAnchor)
        viewHeightConstraint = view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: mapViewSmallAspectRatio)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            viewHeightConstraint,
            
            mapSizeButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 5),
            mapSizeButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -5),
            mapSizeButton.widthAnchor.constraint(equalTo: mapSizeButton.heightAnchor),
            mapSizeButton.heightAnchor.constraint(equalToConstant: 30),
            
            showUserLocationButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 5),
            showUserLocationButton.trailingAnchor.constraint(equalTo: mapSizeButton.leadingAnchor),
            showUserLocationButton.widthAnchor.constraint(equalTo: mapSizeButton.heightAnchor),
            showUserLocationButton.heightAnchor.constraint(equalToConstant: 30),
            
            searchAgainButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 5),
            searchAgainButton.widthAnchor.constraint(equalTo: mapSizeButton.heightAnchor),
            searchAgainButton.heightAnchor.constraint(equalToConstant: 30),
            searchButtonBottomConstraint
        ])
    }
    
    func searchThisArea(_: UIAction) {
        delegate.searchCurrentArea()
    }
    
    func toggleMapViewHeight(_: UIAction) {
        let multiplier = viewHeightConstraint.multiplier == mapViewBigAspectRatio ? mapViewSmallAspectRatio : mapViewBigAspectRatio
        viewHeightConstraint.isActive = false
        viewHeightConstraint = mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: multiplier)
        viewHeightConstraint.isActive = true
        
        let image = viewHeightConstraint.multiplier == 1.0 ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right"
        mapSizeButton.setImage(UIImage(systemName: image), for: .normal)
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.layoutSubviews()
        }
    }
    
    func showUserRegion(_: UIAction) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, radius: 0.1)
        setMapRegion(region: region)
    }
    
    func selectAnnotation(forMapItem mapItem: MKMapItem) {
        guard let annotation = mapView.annotations.compactMap({ $0 as? SSAnnotation}).first(where: { $0.mapItem == mapItem }) else { return }
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    func deselectAnnotations() {
        mapView.selectedAnnotations.forEach {
            mapView.deselectAnnotation($0, animated: true)
        }
    }
    
    func updateMapItems(mapItems: [MKMapItem]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(mapItems.map(SSAnnotation.init))
    }
    
    func setMapRegion(region: MKCoordinateRegion) {
        UIView.animate(withDuration: 0.25) {
            self.mapView.region = region
        }
    }
    
    func toggleSearchButton(shouldShow: Bool) {
        guard shouldShow == (searchButtonBottomConstraint.constant == 0) else { return }
        guard delegate.shouldShowSearchAgainButton() else { return }
        
        let showConstant = searchAgainButton.frame.size.height + 5
        searchButtonBottomConstraint?.constant = shouldShow ? showConstant : 0
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.mapView.layoutSubviews()
        }
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = (view.annotation as? SSAnnotation) else { return }
        delegate.didSelectMapItem(mapItem: annotation.mapItem)
        
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
            delegate.mapRegionDidChange(region: mapView.region)
        }
    }
}
