//
//  View+bothColorSchemesPreview.swift
//  Navvy
//
//  Created by Samuel Shi on 1/4/22.
//

import SwiftUI

extension View {
    @ViewBuilder func bothColorSchemesPreview() -> some View {
        Group {
            self.preferredColorScheme(.dark)
            self.preferredColorScheme(.light)
        }
    }
}
