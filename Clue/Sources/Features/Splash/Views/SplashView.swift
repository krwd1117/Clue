//
//  SplashView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = SplashViewModel()
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 앱 로고
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(.white)
                    .scaleEffect(viewModel.scale)
                    .opacity(viewModel.opacity)
                    .rotationEffect(.degrees(viewModel.rotationAngle))
                
                VStack(spacing: 16) {
                    Text("Clue")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(viewModel.opacity)
                    
                    Text("세션을 확인하는 중...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(viewModel.opacity)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .opacity(viewModel.opacity)
                }
            }
        }
        .onAppear {
            viewModel.startAnimation()
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppRouter())
        .environmentObject(AuthService.shared)
} 

