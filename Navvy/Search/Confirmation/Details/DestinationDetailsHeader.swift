//
//  DestinationDetailsHeader.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import UIKit

class DestinationDetailsHeader: UILabel {
    init(title: String) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .secondaryLabel
        font = .preferredFont(forTextStyle: .footnote)
        text = title
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
