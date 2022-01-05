//
//  SearchMapTableViewCell.swift
//  Navvy
//
//  Created by Samuel Shi on 1/3/22.
//

import UIKit

class SearchMapTableViewCell: UITableViewCell {
    lazy var mapView: SearchMapView = {
        let mapView = SearchMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        contentView.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    func setUp(delegate: SearchMapViewDelegate) {
        mapView.delegate = delegate
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
