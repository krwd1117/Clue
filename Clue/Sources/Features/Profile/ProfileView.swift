//
//  ProfileView.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack {
                Text("프로필")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Button(action: {
                    appState.signOut()
                }, label: {
                    Text("로그아웃")
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Colors.background)
            .navigationTitle("프로필")
        }
    }
}
