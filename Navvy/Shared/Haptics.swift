//
//  Haptics.swift
//  Navvy
//
//  Created by Samuel Shi on 1/8/22.
//

import UIKit

enum HapticEngine {
    static func success() {
        guard hapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func medium() {
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func failure() {
        guard hapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static var hapticsEnabled: Bool {
        SettingsStore.shared.hapticFeedback == .enabled
    }
}
