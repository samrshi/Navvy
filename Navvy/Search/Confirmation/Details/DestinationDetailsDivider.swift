//
//  DestinationDetailsDivider.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import UIKit

class DestinationDetailsDivider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondaryLabel.withAlphaComponent(0.25)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
