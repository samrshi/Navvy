//
//  SettingsOptions.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import Foundation

protocol Defaultable {
    static var defaultValue: Self { get }
}

enum SettingsOption: CaseIterable {
    case systemUnits
    case hapticFeedback
    
    var displayName: String {
        switch self {
        case .systemUnits: return "System Units"
        case .hapticFeedback: return "Haptic Feedback (Vibration)"
        }
    }

    var defaultsKey: String {
        switch self {
        case .systemUnits: return "systemUnits"
        case .hapticFeedback: return "hapticFeedback"
        }
    }
}

extension SettingsOption {
    enum SystemUnits: Int, CaseIterable, Defaultable {
        case imperial
        case metric

        var displayName: String {
            switch self {
            case .metric: return "Metric (km/m)"
            case .imperial: return "Imperial (miles/feet)"
            }
        }

        static var defaultValue: SettingsOption.SystemUnits = .imperial
    }
    
    enum HapticFeedback: Int, CaseIterable, Defaultable {
        case enabled
        case disabled
        
        var displayName: String {
            switch self {
            case .enabled: return "Enabled"
            case .disabled: return "Disabled"
            }
        }
        
        static var defaultValue: SettingsOption.HapticFeedback = .enabled
    }
}
