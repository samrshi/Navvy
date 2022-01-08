//
//  Haptics.swift
//  Navvy
//
//  Created by Samuel Shi on 1/8/22.
//

import UIKit

enum HapticEngine {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
