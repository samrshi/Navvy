//
//  AutocompleteTableViewCell.swift
//  Navvy
//
//  Created by Samuel Shi on 12/13/21.
//

import UIKit

class AutocompleteTableViewCell: UITableViewCell {
    
}

extension UITableViewCell {
    static var reuseId: String {
        return NSStringFromClass(Self.self)
    }
}
