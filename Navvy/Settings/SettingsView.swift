//
//  SettingsView.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var vm = SettingsViewModel()

    var body: some View {
        ScrollView {
            GroupBox("System Units") {
                systemUnitsView
            }
            
            GroupBox("Haptic Feedback") {
                hapticsFeedbackView
            }
        }
        .groupBoxStyle(.secondary)
        .padding(.horizontal)
    }

    private var systemUnitsView: some View {
        Picker("System Units", selection: $vm.systemUnits) {
            ForEach(SettingsOption.SystemUnits.allCases, id: \.self) { option in
                Text(option.displayName)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var hapticsFeedbackView: some View {
        Picker("Haptic Feedback", selection: $vm.hapticFeedback) {
            ForEach(SettingsOption.HapticFeedback.allCases, id: \.self) { option in
                Text(option.displayName)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .background(Color(uiColor: .primaryBackground))
            .bothColorSchemesPreview()
    }
}
