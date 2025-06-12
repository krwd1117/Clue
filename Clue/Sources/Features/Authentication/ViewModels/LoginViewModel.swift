//
//  LoginViewModel.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import Foundation
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var showingAlert = false
    
    private let authService = AuthService.shared
    private var appRouter: AppRouter?
    
    var isLoading: Bool {
        authService.isLoading
    }
    
    // AppRouter 설정 메서드
    func setAppRouter(_ appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - OAuth 로그인 메서드들
    
    func signInWithGoogle() {
        Task {
            do {
                try await authService.signInWithGoogle()
                print("✅ LoginViewModel: Google login successful")
                // 로그인 성공 시 AppRouter를 통해 메인 화면으로 이동
                appRouter?.showMain()
            } catch {
                handleError(error)
            }
        }
    }
    
    func signInWithApple() {
        Task {
            do {
                try await authService.signInWithApple()
                print("✅ LoginViewModel: Apple login successful")
                // 로그인 성공 시 AppRouter를 통해 메인 화면으로 이동
                appRouter?.showMain()
            } catch {
                handleError(error)
            }
        }
    }
    
    // MARK: - 에러 처리
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showingAlert = true
    }
} 