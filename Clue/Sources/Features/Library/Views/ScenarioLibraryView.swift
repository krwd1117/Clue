//
//  ScenarioLibraryView.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

struct ScenarioLibraryView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
            ], spacing: DesignSystem.Spacing.md) {
                
                // Add new scenario card
                TossAddNewCard(
                    title: "새 시나리오",
                    icon: "plus"
                ) {
                    // TODO: Navigate to scenario creation
                    print("새 시나리오 생성")
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}
