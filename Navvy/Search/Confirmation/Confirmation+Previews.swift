//
//  Confirmation+Previews.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import CoreLocation
import MapKit
import SwiftUI

extension DestinationConfirmationVC {
    class WrapperVC: UIViewController {
        lazy var button: UIButton = {
            let button = UIButton(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addAction(UIAction(handler: presentVC), for: .touchUpInside)
            button.setTitle("Present", for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            return button
        }()
        
        func presentVC(_: UIAction) {
            let destination = DestinationConfirmationVC()
            
            let sf = (title: "San Francisco Museum of Art Parking Lot",
                      address: "600 Martin Luther King Jr. Blvd, Apt. 16 Chapel Hill, NC 27514",
                      poi: MKPointOfInterestCategory.parking,
                      coordinate: CLLocationCoordinate2D(latitude: 35.72747, longitude: -79.84748))
            
            let sb = (title: "Starbucks",
                      address: "103 E Franklin St Chapel Hill, NC 27514",
                      poi: MKPointOfInterestCategory.cafe,
                      coordinate: CLLocationCoordinate2D(latitude: 35.72747, longitude: -79.84748))
            
            destination.setUp(title: sf.title, address: sf.address, poi: sf.poi, coordinate: sf.coordinate)
//            destination.setUp(title: sb.title, address: sb.address, poi: sb.poi, coordinate: sb.coordinate)

            if let sheetPresentation = destination.presentationController as? UISheetPresentationController {
                sheetPresentation.detents = [.medium()]
            }
            present(destination, animated: true)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .darkGray
            
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
            
            DispatchQueue.main.async {
                self.presentVC(UIAction(handler: { _ in }))
            }
        }
    }
    
    struct View: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            let vc = DestinationConfirmationVC.WrapperVC()
            return vc
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    }
}
