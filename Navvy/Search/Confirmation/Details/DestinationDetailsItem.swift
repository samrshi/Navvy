//
//  DestinationDetailsItem.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import UIKit

class DestinationDetailsItem: UILabel {
    override init(frame: CGRect) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        font = .preferredFont(forTextStyle: .callout)
        numberOfLines = 0
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
