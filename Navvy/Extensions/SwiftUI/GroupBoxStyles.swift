//
//  GroupBoxStyles.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import SwiftUI

struct SettingsSectionGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.title3.bold())
            
            configuration.content
        }
    }
}

extension GroupBoxStyle where Self == SettingsSectionGroupBoxStyle  {
    static var settingsSection: SettingsSectionGroupBoxStyle { SettingsSectionGroupBoxStyle() }
}

struct SecondaryGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.headline)
            
            configuration.content
        }
        .padding()
        .background(Color(uiColor: .secondaryBackground))
        .cornerRadius(8)
    }
}

extension GroupBoxStyle where Self == SecondaryGroupBoxStyle  {
    static var secondary: SecondaryGroupBoxStyle { SecondaryGroupBoxStyle() }
}
