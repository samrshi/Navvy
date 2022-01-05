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
            .groupBoxStyle(.secondary)
        }
        .padding(.horizontal)
    }

    var systemUnitsView: some View {
        Picker("System Units", selection: $vm.systemUnits) {
            ForEach(SettingsOption.SystemUnits.allCases, id: \.self) { option in
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
