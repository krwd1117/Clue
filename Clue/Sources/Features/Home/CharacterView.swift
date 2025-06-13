//
//  CharacterView.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

struct CharacterView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("캐릭터 생성")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Colors.background)
            .navigationTitle("캐릭터")
        }
    }
}
