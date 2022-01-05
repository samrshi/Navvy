//
//  FavoritesVC.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import UIKit

class FavoritesVC: UIViewController {
    lazy var comingSoonLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Coming Soon..."
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primaryBackground
        
        view.addSubview(comingSoonLabel)
        NSLayoutConstraint.activate([
            comingSoonLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comingSoonLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
