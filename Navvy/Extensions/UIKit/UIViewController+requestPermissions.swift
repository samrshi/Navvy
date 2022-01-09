//
//  UIViewController+requestPermissions.swift
//  Navvy
//
//  Created by Samuel Shi on 1/9/22.
//

import UIKit

enum LocationPermissionsRequestType { case firstTime, currentlyDenied }

extension UIViewController {
    func showRequestLocationPermissions(requestType: LocationPermissionsRequestType, completion: @escaping () -> Void = {}) {
        var title: String
        var description: String
        var action: () -> Void
        var buttonTitle: String

        switch requestType {
        case .firstTime:
            title = "Enable Location Permissions"
            description = "Navvy uses your location to help you search\nfor nearby locations and to show how to\nget to your destination."
            buttonTitle = "Okay, I understand!"
            action = {
                LocationManager.shared.requestPreciseLocation()
                completion()
                UserDefaults.standard.set(true, forKey: "hasShownOnboarding")
            }
        case .currentlyDenied:
            title = "Enable Location Permissions"
            description = "Currently, Navvy does not have access to your location. To continue, enable locations permissions in Settings."
            buttonTitle = "Go To Settings"
            action = {
                completion()
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }

        showInformationVC(image: UIImage(named: "navvy-ill")!,
                          title: title,
                          description: description,
                          buttonTitle: buttonTitle,
                          action: action)
    }
}
