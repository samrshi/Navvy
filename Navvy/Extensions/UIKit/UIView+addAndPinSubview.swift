//
//  UIView+addAndPinSubview.swift
//  Navvy
//
//  Created by Samuel Shi on 1/3/22.
//

import UIKit

extension UIView {
    func addAndPinSubview(_ view: UIView, leading: CGFloat = 0, trailing: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) {
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing),
            view.topAnchor.constraint(equalTo: topAnchor, constant: top),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom),
        ])
    }
    
    func addAndPinSubviewToSafeArea(_ view: UIView, leading: CGFloat = 0, trailing: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) {
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: leading),
            view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: trailing),
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: top),
            view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottom),
        ])
    }
}
