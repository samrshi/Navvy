//
//  UIViewController+showError.swift
//  Navvy
//
//  Created by Samuel Shi on 1/8/22.
//

import UIKit
import Toast

extension UIViewController {
    func showToastError(title: String, message: String) {
        let toast = Toast.default(image: UIImage(systemName: "exclamationmark.triangle")!,
                                  imageTint: .systemRed,
                                  title: title,
                                  subtitle: message,
                                  config: ToastConfiguration(autoHide: true, attachTo: view))
        toast.show()
    }
}
