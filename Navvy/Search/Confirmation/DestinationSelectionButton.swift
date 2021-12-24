//
//  DestinationSelectionButton.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import UIKit

class DestinationSelectionButton: UIButton {
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "arrow.up")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .label
        return imageView
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBlue
        layer.cornerRadius = 10
        
        addSubview(contentView)
        contentView.addSubview(arrowImage)
        contentView.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//            contentView.leadingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            arrowImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            arrowImage.widthAnchor.constraint(equalToConstant: 25),
            arrowImage.heightAnchor.constraint(equalTo: arrowImage.widthAnchor),
            arrowImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            arrowImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            distanceLabel.leadingAnchor.constraint(equalTo: arrowImage.trailingAnchor, constant: 5),
            distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            distanceLabel.topAnchor.constraint(equalTo: arrowImage.topAnchor),
            distanceLabel.bottomAnchor.constraint(equalTo: arrowImage.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
