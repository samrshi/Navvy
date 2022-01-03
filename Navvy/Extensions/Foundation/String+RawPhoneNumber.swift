//
//  String+RawPhoneNumber.swift
//  Navvy
//
//  Created by Samuel Shi on 1/3/22.
//

import Foundation

extension String {
  func rawPhoneNumber() -> String {
    return self.components(separatedBy: .alphanumerics.inverted).joined()
  }
}
