//
//  DestinationTableViewCell.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import Combine
import MapKit
import UIKit

class DestinationTableViewCell: UITableViewCell {
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .caption1)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    lazy var textContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var iconView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var arrow: UIImageView = {
        let image = UIImage(systemName: "arrow.up")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
        
    lazy var distanceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    var navigationVM: NavigationViewModel!
    var angleCancellable: AnyCancellable?
    var distanceCancellable: AnyCancellable?
    
    func setUp(navigationVM: NavigationViewModel, showCustomSeparator: Bool) {
        self.navigationVM = navigationVM
        self.separatorView.isHidden = !showCustomSeparator
        
        nameLabel.text = navigationVM.destinationName
        subtitleLabel.text = navigationVM.destinationSubtitle
        iconView.image = UIImage(named: navigationVM.destinationCategory.toIcon())
        
        angleCancellable = navigationVM.$angleToDestination
            .receive(on: DispatchQueue.main)
            .sink { [weak self] angle in
                self?.rotateArrow(angle: angle)
            }
        
        distanceCancellable = navigationVM.$distanceToDestination
            .receive(on: DispatchQueue.main)
            .weaklyAssign(to: \.text, on: distanceLabel)
    }
    
    func rotateArrow(angle: Double) {
        UIView.animate(withDuration: 0.05) { [weak self] in
            guard let self = self else { return }
            self.arrow.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        contentView.addSubview(textContainer)
        textContainer.addSubview(iconView)
        textContainer.addSubview(nameLabel)
        
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(arrow)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(separatorView)
        
        iconView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        nameLabel.setContentHuggingPriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            iconView.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            iconView.bottomAnchor.constraint(equalTo: subtitleLabel.bottomAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: textContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),
            
            textContainer.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            textContainer.trailingAnchor.constraint(equalTo: distanceLabel.leadingAnchor, constant: -5),
            textContainer.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textContainer.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            distanceLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor, constant: 15),
            distanceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            distanceLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            arrow.widthAnchor.constraint(equalToConstant: 30),
            arrow.heightAnchor.constraint(equalTo: arrow.widthAnchor),
            arrow.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor),
            arrow.bottomAnchor.constraint(equalTo: distanceLabel.topAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let displayScale = window?.screen.scale
        let pixelLength = displayScale.map { 1 / $0 } ?? 0.5
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: pixelLength),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        navigationVM = nil
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
