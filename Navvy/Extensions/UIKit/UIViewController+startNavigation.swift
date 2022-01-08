//
//  UIVC+startNavigation.swift
//  Navvy
//
//  Created by Samuel Shi on 1/7/22.
//

import UIKit

extension DestinationConfirmationVCDelegate where Self: UIViewController {
    func startNavigation(navigationVM: NavigationViewModel) {
        let vc = DestinationConfirmationVC()
        vc.setUp(vm: navigationVM, delegate: self)

        if let presentationController = vc.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
        }

        present(vc, animated: true)
    }
}
