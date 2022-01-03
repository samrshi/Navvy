//
//  SelfSizingHostingController.swift
//  Navvy
//
//  Created by Samuel Shi on 1/3/22.
//

import SwiftUI

class SelfSizingHostingController<Content>: UIHostingController<Content> where Content: View {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.invalidateIntrinsicContentSize()
    }
}
