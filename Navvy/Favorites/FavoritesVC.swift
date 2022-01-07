//
//  FavoritesVC.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import UIKit
import SwiftUI

class FavoritesVC: UIViewController {
    lazy var favoritesVC: UIHostingController<FavoritesView> = {
        let hosting = UIHostingController(rootView: FavoritesView())
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        return hosting
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primaryBackground

        addChildViewController(child: favoritesVC)
        NSLayoutConstraint.activate([
            favoritesVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            favoritesVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            favoritesVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            favoritesVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
