//
//  DestinationDetailsView.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import UIKit

class DestinationDetailsView: UIView {

    #warning("abstract")
    
    lazy var detailsContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var detailsHeader: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 18)
        label.text = "Details"
        return label
    }()
    
    lazy var addressHeader = DestinationDetailsHeader(title: "Address")
    lazy var addressLabel = DestinationDetailsItem(frame: .zero)
    
    lazy var detailsDivider = DestinationDetailsDivider(frame: .zero)
    
    lazy var coordinatesHeader = DestinationDetailsHeader(title: "Coordinates")
    lazy var coordinatesLabel = DestinationDetailsItem(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(detailsHeader)
        addSubview(detailsContainer)
        detailsContainer.addSubview(addressHeader)
        detailsContainer.addSubview(addressLabel)
        detailsContainer.addSubview(detailsDivider)
        detailsContainer.addSubview(coordinatesHeader)
        detailsContainer.addSubview(coordinatesLabel)
        
        NSLayoutConstraint.activate([
            
            detailsHeader.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailsHeader.trailingAnchor.constraint(equalTo: trailingAnchor),
            detailsHeader.topAnchor.constraint(equalTo: topAnchor),
            
            detailsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            detailsContainer.topAnchor.constraint(equalTo: detailsHeader.bottomAnchor, constant: 5),
            
            addressHeader.topAnchor.constraint(equalTo: detailsContainer.topAnchor, constant: 18),
            addressHeader.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: 18),
            addressHeader.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor, constant: -18),
            
            addressLabel.topAnchor.constraint(equalTo: addressHeader.bottomAnchor, constant: 2),
            addressLabel.leadingAnchor.constraint(equalTo: addressHeader.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: addressHeader.trailingAnchor),
            
            detailsDivider.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 10),
            detailsDivider.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            detailsDivider.trailingAnchor.constraint(equalTo: addressLabel.trailingAnchor),
            detailsDivider.heightAnchor.constraint(equalToConstant: 1),
            
            coordinatesHeader.topAnchor.constraint(equalTo: detailsDivider.bottomAnchor, constant: 10),
            coordinatesHeader.leadingAnchor.constraint(equalTo: detailsDivider.leadingAnchor),
            coordinatesHeader.trailingAnchor.constraint(equalTo: detailsDivider.trailingAnchor),
            
            coordinatesLabel.topAnchor.constraint(equalTo: coordinatesHeader.bottomAnchor, constant: 2),
            coordinatesLabel.leadingAnchor.constraint(equalTo: coordinatesHeader.leadingAnchor),
            coordinatesLabel.trailingAnchor.constraint(equalTo: coordinatesHeader.trailingAnchor),
            coordinatesLabel.bottomAnchor.constraint(equalTo: detailsContainer.bottomAnchor, constant: -18),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
