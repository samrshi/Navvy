//
//  NavigationVC.swift
//  Navvy
//
//  Created by Samuel Shi on 1/2/22.
//

import Combine
import UIKit

class NavigationVC: UIViewController {
    var cancellables: [AnyCancellable] = []
    var timer: AnyCancellable?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.closeAction()
        }), for: .touchUpInside)
        return button
    }()
    
    lazy var arrowView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.up")!)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isAccessibilityElement = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32)
        return label
    }()
    
    var vm: NavigationViewModel!
    var isGoingCorrectDirection: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primaryBackground
        
        view.addSubview(titleLabel)
        view.addSubview(arrowView)
        view.addSubview(closeButton)
        view.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            arrowView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            arrowView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            arrowView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 2 / 3),
            arrowView.heightAnchor.constraint(equalTo: arrowView.widthAnchor),
            
            distanceLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            distanceLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            distanceLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if LocationManager.shared.locationPermissionsAreDenied {
            showRequestLocationPermissions(requestType: .currentlyDenied)
        }
    }
    
    func setUp(vm: NavigationViewModel) {
        self.vm = vm
        titleLabel.text = vm.destinationName
        
        vm.$angleToDestination
            .receive(on: DispatchQueue.main)
            .sink { [weak self] angle in
                self?.didReceiveAngle(angle: angle)
            }
            .store(in: &cancellables)
        
        vm.$distanceToDestination
            .receive(on: DispatchQueue.main)
            .weaklyAssign(to: \.text, on: distanceLabel)
            .store(in: &cancellables)
        
        vm.$accessibilityAngleDescription
            .receive(on: DispatchQueue.main)
            .weaklyAssign(to: \.accessibilityLabel, on: arrowView)
            .store(in: &cancellables)
    }
    
    func closeAction() {
        dismiss(animated: true)
        HapticEngine.medium()
    }
    
    func didReceiveAngle(angle: Double) {
        let transform = CGAffineTransform(rotationAngle: angle)
        arrowView.transform = transform
        
        let boundedAngle = NavigationViewModel.boundedAngleInDegrees(angleInRadians: angle)
        
        if abs(boundedAngle) > 10 && timer == nil {
            return
        } else if abs(boundedAngle) > 10 && timer != nil {
            HapticEngine.failure()
            timer = nil
            return
        } else if abs(boundedAngle) <= 10 && timer != nil {
            return
        }
        
        HapticEngine.success()
        timer = Timer.publish(every: 0.75, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                HapticEngine.medium()
            }
    }
}
