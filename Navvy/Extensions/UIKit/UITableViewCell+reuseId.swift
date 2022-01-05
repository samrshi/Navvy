//
//  UITableViewCell+reuseId.swift
//  Navvy
//
//  Created by Samuel Shi on 1/5/22.
//

import UIKit

extension UITableViewCell {
    static var reuseId: String {
        return NSStringFromClass(Self.self)
    }
}
