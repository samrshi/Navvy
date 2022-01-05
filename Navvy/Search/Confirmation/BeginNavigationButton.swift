//
//  DestinationSelectionButton.swift
//  Navvy
//
//  Created by Samuel Shi on 12/24/21.
//

import UIKit

class BeginNavigationButton: UIButton {
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
        imageView.tintColor = .white
        return imageView
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .systemBlue
        self.configuration = configuration
        
        addSubview(contentView)
        contentView.addSubview(arrowImage)
        contentView.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            arrowImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            arrowImage.widthAnchor.constraint(equalToConstant: 20),
            arrowImage.heightAnchor.constraint(equalTo: arrowImage.widthAnchor),
            arrowImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            distanceLabel.leadingAnchor.constraint(equalTo: arrowImage.trailingAnchor, constant: 5),
            distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            distanceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    
    func setDistance(newDistance: String) {
        distanceLabel.text = newDistance
    }
    
    func setAngle(newAngle: Double) {
        arrowImage.transform = CGAffineTransform(rotationAngle: newAngle)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
