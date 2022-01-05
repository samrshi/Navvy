//
//  SettingsVM.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import Foundation

class SettingsViewModel: ObservableObject {
    @Published var systemUnits: SettingsOption.SystemUnits = SettingsStore.shared.systemUnits {
        didSet {
            SettingsStore.shared.systemUnits = systemUnits
        }
    }
}
