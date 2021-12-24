//
//  DestinationConfirmationVC.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import Combine
import MapKit
import SwiftUI
import UIKit

class DestinationConfirmationVC: UIViewController {
    var cancellables = [AnyCancellable]()
    
    lazy var pointOfInterestImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var callToActionButton: DestinationSelectionButton = {
        let button = DestinationSelectionButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        // button.addAction(UIAction, for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .secondaryBackground
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 20)
        // button.addAction(UIAction, for: .touchUpInside)
        return button
    }()
    
    lazy var detailsContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var detailsHeader: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 18)
        label.text = "Details"
        return label
    }()
    
    lazy var addressHeader = DestinationDetailsHeader(title: "Address")
    lazy var addressLabel = DestinationDetailsItem(frame: .zero)
    
    lazy var detailsDivider = DestinationDetailsDivider(frame: .zero)
    
    lazy var coordinatesHeader = DestinationDetailsHeader(title: "Coordinates")
    lazy var coordinatesLabel = DestinationDetailsItem(frame: .zero)
    
    var navigationVM: NavigationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primaryBackground
        overrideUserInterfaceStyle = .dark
        
        view.addSubview(pointOfInterestImage)
        view.addSubview(titleLabel)
        view.addSubview(callToActionButton)
        view.addSubview(cancelButton)
        
        view.addSubview(detailsHeader)
        view.addSubview(detailsContainer)
        detailsContainer.addSubview(addressHeader)
        detailsContainer.addSubview(addressLabel)
        detailsContainer.addSubview(detailsDivider)
        detailsContainer.addSubview(coordinatesHeader)
        detailsContainer.addSubview(coordinatesLabel)
        
        NSLayoutConstraint.activate([
            pointOfInterestImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            pointOfInterestImage.widthAnchor.constraint(equalToConstant: 45),
            pointOfInterestImage.heightAnchor.constraint(equalTo: pointOfInterestImage.widthAnchor),
            pointOfInterestImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: pointOfInterestImage.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            callToActionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            callToActionButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -5),
            
            cancelButton.topAnchor.constraint(equalTo: callToActionButton.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: callToActionButton.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 5),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            detailsHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            detailsHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            detailsHeader.topAnchor.constraint(equalTo: callToActionButton.bottomAnchor, constant: 30),
            
            detailsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            detailsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            detailsContainer.topAnchor.constraint(equalTo: detailsHeader.bottomAnchor, constant: 5),
            
            addressHeader.topAnchor.constraint(equalTo: detailsContainer.topAnchor, constant: 18),
            addressHeader.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 18),
            addressHeader.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor, constant: -18),
            
            addressLabel.topAnchor.constraint(equalTo: addressHeader.bottomAnchor, constant: 2),
            addressLabel.leadingAnchor.constraint(equalTo: addressHeader.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: addressHeader.trailingAnchor),
            
            detailsDivider.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 10),
            detailsDivider.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            detailsDivider.trailingAnchor.constraint(equalTo: addressLabel.trailingAnchor),
            detailsDivider.heightAnchor.constraint(equalToConstant: 1),
            
            coordinatesHeader.topAnchor.constraint(equalTo: detailsDivider.bottomAnchor, constant: 10),
            coordinatesHeader.leadingAnchor.constraint(equalTo: detailsDivider.leadingAnchor),
            coordinatesHeader.trailingAnchor.constraint(equalTo: detailsDivider.trailingAnchor),
            
            coordinatesLabel.topAnchor.constraint(equalTo: coordinatesHeader.bottomAnchor, constant: 2),
            coordinatesLabel.leadingAnchor.constraint(equalTo: coordinatesHeader.leadingAnchor),
            coordinatesLabel.trailingAnchor.constraint(equalTo: coordinatesHeader.trailingAnchor),
            coordinatesLabel.bottomAnchor.constraint(equalTo: detailsContainer.bottomAnchor, constant: -18),
        ])
    }

    func setUp(vm: NavigationViewModel) {
        navigationVM = vm
        
        titleLabel.text = vm.destinationName
        addressLabel.text = vm.destinationSubtitle
        coordinatesLabel.text = vm.mapItem.placemark.coordinate.formatted
        pointOfInterestImage.image = UIImage(named: vm.mapItem.pointOfInterestCategory.toIcon())
        
        vm.$distanceToDestination
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distance in
                self?.callToActionButton.distanceLabel.text = "\(distance)"
            }
            .store(in: &cancellables)
        
        vm.$angleToDestination
            .receive(on: DispatchQueue.main)
            .sink { [weak self] angle in
                self?.callToActionButton.arrowImage.transform = CGAffineTransform(rotationAngle: angle)
            }
            .store(in: &cancellables)
    }

    func setUp(title: String, address: String, poi: MKPointOfInterestCategory?, coordinate: CLLocationCoordinate2D, distance: String = "25 mi") {
        titleLabel.text = title
        addressLabel.text = address
        coordinatesLabel.text = coordinate.formatted
        callToActionButton.distanceLabel.text = "\(distance)"
        pointOfInterestImage.image = UIImage(named: poi.toIcon())
    }
}

struct DestinationConfirmationVC_Previews: PreviewProvider {
    static var previews: some View {
        DestinationConfirmationVC.View()
            .preferredColorScheme(.dark)
    }
}
