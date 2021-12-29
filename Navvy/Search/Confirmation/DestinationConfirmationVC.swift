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
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var pointOfInterestImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title1)
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
        let button = UIButton(type: .close)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: closeAction), for: .touchUpInside)
        button.tintColor = .blue
        return button
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "heart")
        configuration.baseBackgroundColor = .tertiaryBackground
        configuration.baseForegroundColor = .label
        button.configuration = configuration
        
        return button
    }()
    
    var detailsContent = [DetailsItem]()
    
    lazy var detailsHeader: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "Details"
        return label
    }()
    
    lazy var detailsTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailsTableViewCell")
        tableView.dataSource = self
        tableView.backgroundColor = .tertiaryBackground
        tableView.layer.cornerRadius = 10
        return tableView
    }()
    
    var navigationVM: NavigationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondaryBackground
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(pointOfInterestImage)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(callToActionButton)
        scrollView.addSubview(favoriteButton)
        
        scrollView.addSubview(detailsHeader)
        scrollView.addSubview(detailsTableView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pointOfInterestImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            pointOfInterestImage.widthAnchor.constraint(equalToConstant: 45),
            pointOfInterestImage.heightAnchor.constraint(equalTo: pointOfInterestImage.widthAnchor),
            pointOfInterestImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: pointOfInterestImage.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            
            cancelButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            cancelButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            callToActionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            callToActionButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -5),

            favoriteButton.leadingAnchor.constraint(equalTo: callToActionButton.trailingAnchor, constant: 5),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            favoriteButton.topAnchor.constraint(equalTo: callToActionButton.topAnchor),
            favoriteButton.heightAnchor.constraint(equalTo: callToActionButton.heightAnchor),
            favoriteButton.widthAnchor.constraint(equalTo: favoriteButton.heightAnchor),

            detailsHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            detailsHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            detailsHeader.topAnchor.constraint(equalTo: callToActionButton.bottomAnchor, constant: 30),
            
            detailsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            detailsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            detailsTableView.topAnchor.constraint(equalTo: detailsHeader.bottomAnchor, constant: 5),
            detailsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func setUp(vm: NavigationViewModel) {
        navigationVM = vm
        
        titleLabel.text = vm.destinationName
        pointOfInterestImage.image = UIImage(named: vm.mapItem.pointOfInterestCategory.toIcon())
        
        var details = [DetailsItem]()
        
        if let address = vm.destinationSubtitle {
            details.append(DetailsItem(header: "Address", content: address))
        }
        
        let coordinates = vm.destinationCoordinates.formatted
        details.append(DetailsItem(header: "Coordinates", content: coordinates))
        
        if let url = vm.destinationURL {
            details.append(DetailsItem(header: "Website", content: url.absoluteString))
        }
        
        if let phoneNumber = vm.destinationPhoneNumber {
            details.append(DetailsItem(header: "Phone Number", content: phoneNumber))
        }
        
        self.detailsContent = details
        detailsTableView.reloadData()
        
        callToActionButton.distanceLabel.text = vm.distanceToDestination
        vm.$distanceToDestination
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distance in
                self?.callToActionButton.distanceLabel.text = distance
            }
            .store(in: &cancellables)
        
        callToActionButton.arrowImage.transform = CGAffineTransform(rotationAngle: vm.angleToDestination)
        vm.$angleToDestination
            .receive(on: DispatchQueue.main)
            .sink { [weak self] angle in
                self?.callToActionButton.arrowImage.transform = CGAffineTransform(rotationAngle: angle)
            }
            .store(in: &cancellables)
    }

    func setUp(title: String, address: String, poi: MKPointOfInterestCategory?, coordinate: CLLocationCoordinate2D, distance: String = "25 mi") {
        titleLabel.text = title
        
        var details = [DetailsItem]()
        details.append(DetailsItem(header: "Address", content: address))
        details.append(DetailsItem(header: "Coordinates", content: coordinate.formatted))
        self.detailsContent = details
        detailsTableView.reloadData()
        
        callToActionButton.distanceLabel.text = "\(distance)"
        pointOfInterestImage.image = UIImage(named: poi.toIcon())
    }
    
    func closeAction(_: UIAction) {
        dismiss(animated: true)
    }
}

extension DestinationConfirmationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsTableViewCell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        
        configuration.text = detailsContent[indexPath.row].header
        configuration.textProperties.font = .preferredFont(forTextStyle: .footnote)
        configuration.textProperties.color = .secondaryLabel
        
        configuration.secondaryText = detailsContent[indexPath.row].content
        configuration.secondaryTextProperties.font = .preferredFont(forTextStyle: .callout)
        configuration.secondaryTextProperties.color = .label
        
        cell.contentConfiguration = configuration
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        detailsContent.count
    }
}

struct DestinationConfirmationVC_Previews: PreviewProvider {
    static var previews: some View {
        DestinationConfirmationVC.View()
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraSmall)
    }
}
