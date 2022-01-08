//
//  FavoritesEmptyView.swift
//  Navvy
//
//  Created by Samuel Shi on 1/8/22.
//

import UIKit

class FavoritesEmptyView: UIView {
    lazy var heartImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    lazy var emptyStateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "heart")?.withTintColor(.secondaryLabel)

        label.text = "Your favorites list is empty."
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(heartImageView)
        addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            heartImageView.topAnchor.constraint(equalTo: topAnchor),
            heartImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            heartImageView.widthAnchor.constraint(equalToConstant: 75),
            heartImageView.heightAnchor.constraint(equalTo: heartImageView.widthAnchor),
            
            emptyStateLabel.topAnchor.constraint(equalTo: heartImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            widthAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
