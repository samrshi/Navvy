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

protocol DestinationConfirmationVCDelegate: AnyObject {
    func didDismissDestinationConfirmation()
}

class DestinationConfirmationVC: UIViewController {
    var cancellables = [AnyCancellable]()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var scrollViewContent: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .close)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.closeAction()
        }, for: .touchUpInside)
        return button
    }()
    
    lazy var beginNavigationButton: BeginNavigationButton = {
        let button = BeginNavigationButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.beginNavigationAction()
        }, for: .touchUpInside)
        return button
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.favoriteAction()
        }), for: .touchUpInside)
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "heart")
        configuration.baseBackgroundColor = .tertiaryBackground
        configuration.baseForegroundColor = .label
        button.configuration = configuration

        return button
    }()
        
    func buildDetailsVC(address: String?, coordinates: String, phoneNumber: String?, url: URL?) -> UIHostingController<DestinationConfirmationDetailsView> {
        let rootView = DestinationConfirmationDetailsView(address: address,
                                                          coordinates: coordinates,
                                                          phoneNumber: phoneNumber,
                                                          url: url)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
    
    var detailsVC: UIHostingController<DestinationConfirmationDetailsView>!
    
    var navigationVM: NavigationViewModel!
    weak var delegate: DestinationConfirmationVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondaryBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContent)
        
        scrollViewContent.addSubview(pointOfInterestImage)
        scrollViewContent.addSubview(titleLabel)
        scrollViewContent.addSubview(cancelButton)
        
        scrollViewContent.addSubview(beginNavigationButton)
        scrollViewContent.addSubview(favoriteButton)
        
        addChildViewController(child: detailsVC, toView: scrollViewContent)
        
        let scrollViewContentHeightConstraint = scrollViewContent.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        scrollViewContentHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollViewContent.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollViewContent.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollViewContent.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollViewContent.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            scrollViewContent.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            scrollViewContentHeightConstraint,
            
            pointOfInterestImage.leadingAnchor.constraint(equalTo: scrollViewContent.leadingAnchor, constant: 15),
            pointOfInterestImage.widthAnchor.constraint(equalToConstant: 45),
            pointOfInterestImage.heightAnchor.constraint(equalTo: pointOfInterestImage.widthAnchor),
            pointOfInterestImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: pointOfInterestImage.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: scrollViewContent.topAnchor, constant: 25),
            
            cancelButton.topAnchor.constraint(equalTo: scrollViewContent.topAnchor, constant: 25),
            cancelButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
            cancelButton.trailingAnchor.constraint(equalTo: scrollViewContent.trailingAnchor, constant: -15),
            cancelButton.widthAnchor.constraint(equalTo: cancelButton.heightAnchor),
            
            beginNavigationButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            beginNavigationButton.leadingAnchor.constraint(equalTo: scrollViewContent.leadingAnchor, constant: 15),
            beginNavigationButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -5),
            
            favoriteButton.leadingAnchor.constraint(equalTo: beginNavigationButton.trailingAnchor, constant: 5),
            favoriteButton.trailingAnchor.constraint(equalTo: scrollViewContent.trailingAnchor, constant: -15),
            favoriteButton.topAnchor.constraint(equalTo: beginNavigationButton.topAnchor),
            favoriteButton.heightAnchor.constraint(equalTo: beginNavigationButton.heightAnchor),
            favoriteButton.widthAnchor.constraint(equalTo: favoriteButton.heightAnchor),
            
            detailsVC.view.leadingAnchor.constraint(equalTo: scrollViewContent.leadingAnchor, constant: 15),
            detailsVC.view.trailingAnchor.constraint(equalTo: scrollViewContent.trailingAnchor, constant: -15),
            detailsVC.view.topAnchor.constraint(equalTo: beginNavigationButton.bottomAnchor, constant: 30),
            detailsVC.view.bottomAnchor.constraint(equalTo: scrollViewContent.bottomAnchor),
        ])
    }
    
    func setUp(vm: NavigationViewModel, delegate: DestinationConfirmationVCDelegate) {
        navigationVM = vm
        self.delegate = delegate
        
        titleLabel.text = vm.destinationName
        pointOfInterestImage.image = UIImage(named: vm.mapItem.pointOfInterestCategory.toIcon())
        
        detailsVC = buildDetailsVC(
            address: vm.destinationSubtitle,
            coordinates: vm.destinationCoordinates.formatted,
            phoneNumber: vm.destinationPhoneNumber,
            url: vm.destinationURL)
        
        beginNavigationButton.setDistance(newDistance: vm.distanceToDestination)
        vm.$distanceToDestination
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distance in
                self?.beginNavigationButton.setDistance(newDistance: distance)
            }
            .store(in: &cancellables)
        
        beginNavigationButton.setAngle(newAngle: vm.angleToDestination)
        vm.$angleToDestination
            .receive(on: DispatchQueue.main)
            .sink { [weak self] angle in
                self?.beginNavigationButton.setAngle(newAngle: angle)
            }
            .store(in: &cancellables)
    }

    func setUp(title: String, address: String, poi: MKPointOfInterestCategory?, coordinate: CLLocationCoordinate2D, distance: String = "25 mi") {
        titleLabel.text = title
        
        beginNavigationButton.distanceLabel.text = "\(distance)"
        pointOfInterestImage.image = UIImage(named: poi.toIcon())
    }
    
    func beginNavigationAction() {
        let vc = NavigationVC()
        vc.setUp(vm: navigationVM)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func favoriteAction() {
        FavoritesDataStore.shared.save(destination: Destination(mapItem: navigationVM.mapItem))
    }
    
    func closeAction() {
        delegate.didDismissDestinationConfirmation()
        dismiss(animated: true)
    }
}

struct DestinationConfirmationVC_Previews: PreviewProvider {
    static var previews: some View {
        DestinationConfirmationVC.View()
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraSmall)
    }
}
