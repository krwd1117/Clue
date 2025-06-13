//
//  LibraryView.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("보관함")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Colors.background)
            .navigationTitle("보관함")
        }
    }
}
