//
//  UIViewController+addChildViewController.swift
//  Navvy
//
//  Created by Samuel Shi on 12/15/21.
//

import UIKit

extension UIViewController {
    func addChildViewController(child: UIViewController) {
        view.addSubview(child.view)
        addChild(child)
        child.didMove(toParent: self)
    }
}
