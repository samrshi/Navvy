//
//  UIViewController+showInformationVC.swift
//  Navvy
//
//  Created by Samuel Shi on 1/9/22.
//

import UIKit
import SwiftUI

extension UIViewController {
    func showInformationVC(image: UIImage, title: String, description: String, buttonTitle: String, action: @escaping () -> Void) {
        let action: () -> Void = { [weak self] in
            action()
            
            self?.presentedViewController?.dismiss(animated: true)
        }
        
        let rootView = InformationView(image: image,
                                      title: title,
                                      description: description,
                                      buttonText: buttonTitle,
                                      action: action)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .primaryBackground
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
}
