//
//  SettingsStore.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import Foundation

class SettingsStore {
    static let shared = SettingsStore()
    
    init() {
        guard !defaultSettingsHaveBeenSet else { return }
        
        systemUnits = .imperial
        defaultSettingsHaveBeenSet = true
    }
    
    var defaultSettingsHaveBeenSet: Bool {
        get {
            UserDefaults.standard.bool(forKey: "defaultSettingsHaveBeenSet")
        } set {
            UserDefaults.standard.set(newValue, forKey: "defaultSettingsHaveBeenSet")
        }
    }
    
    var systemUnits: SettingsOption.SystemUnits {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: SettingsOption.systemUnits.defaultsKey)
            return SettingsOption.SystemUnits(rawValue: rawValue) ?? .defaultValue
        } set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SettingsOption.systemUnits.defaultsKey)
        }
    }
}
