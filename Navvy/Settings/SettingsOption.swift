//
//  SettingsOptions.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import Foundation

enum SettingsOption: CaseIterable {
    case systemUnits
    
    var displayName: String {
        switch self {
        case .systemUnits: return "System Units"
        }
    }
    
    var defaultsKey: String {
        switch self {
        case .systemUnits: return "systemUnits"
        }
    }
}

extension SettingsOption {
    enum SystemUnits: Int, CaseIterable, Defaultable {
        case imperial
        case metric

        var displayName: String {
            switch self {
            case .metric:   return "Metric (km/m)"
            case .imperial: return "Imperial (miles/feet)"
            }
        }
        
        static var defaultValue: SettingsOption.SystemUnits = .imperial
    }
}

protocol Defaultable {
    static var defaultValue: Self { get }
}
