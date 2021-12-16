//
//  ViewController.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import UIKit

class ViewController: UIViewController {
    lazy var locationSearchVC: UIViewController = {
        let vc = LocationSearchVC()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Navvy"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        
        
        addChild(locationSearchVC)
        view.addSubview(locationSearchVC.view)
        locationSearchVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            locationSearchVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            locationSearchVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            locationSearchVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            locationSearchVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
