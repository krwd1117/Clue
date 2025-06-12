//
//  SplashViewModel.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import Foundation
import SwiftUI

@MainActor
class SplashViewModel: ObservableObject {
    @Published var opacity: Double = 0.0
    @Published var scale: Double = 0.8
    @Published var rotationAngle: Double = 0.0
    
    private let authService = AuthService.shared
    
    // MARK: - Animation
    
    func startAnimation() {
        print("🎬 SplashViewModel: Starting animations")
        
        // 페이드 인 & 스케일 애니메이션
        withAnimation(.easeInOut(duration: 1.5)) {
            opacity = 1.0
            scale = 1.0
        }
        
        // 회전 애니메이션
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360.0
        }
        
        // 세션 체크 시작
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Session Check
    
    private func checkSession() async {
        print("🔍 SplashViewModel: Checking session...")
        
        // 최소 2초 동안 스플래시 화면 표시
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        do {
            // 세션 새로고침 시도
            try await authService.refreshSession()
            print("✅ SplashViewModel: Session check completed - authenticated: \(authService.isAuthenticated)")
        } catch {
            print("❌ SplashViewModel: Session check failed - \(error)")
        }
        
        // 세션 체크 완료 알림
        NotificationCenter.default.post(name: .sessionCheckCompleted, object: nil)
    }
    
    // MARK: - Computed Properties
    
    var isAuthenticated: Bool {
        authService.isAuthenticated
    }
} 
