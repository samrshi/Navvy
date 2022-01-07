//
//  QuickSearchTableViewCell.swift
//  Navvy
//
//  Created by Samuel Shi on 1/7/22.
//

import UIKit
import MapKit
import SwiftUI

class QuickSearchTableViewCell: UITableViewCell {
    var didSelectCategory: (MKPointOfInterestCategory) -> Void
    
    lazy var quickSearchView: UIView = {
        let hostingController = UIHostingController(rootView: QuickSearchView(didSelectCategory: didSelectCategory))
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        return hostingController.view
    }()
    
    init(didSelectCategory: @escaping (MKPointOfInterestCategory) -> Void) {
        self.didSelectCategory = didSelectCategory
        super.init(style: .default, reuseIdentifier: QuickSearchTableViewCell.reuseId)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(quickSearchView)
        NSLayoutConstraint.activate([
            quickSearchView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            quickSearchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quickSearchView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            quickSearchView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
