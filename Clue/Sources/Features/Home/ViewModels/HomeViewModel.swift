//
//  HomeViewModel.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    
    private let authService = AuthService.shared
    private var appRouter: AppRouter?
    private var navigationRouter: NavigationRouter?
    
    // MARK: - Setup
    
    func setup() {
        print("🏠 HomeViewModel: Setting up home view")
        // 홈 화면 초기화 로직
    }
    
    func setRouters(appRouter: AppRouter, navigationRouter: NavigationRouter) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Main Actions
    
    func startCharacterGeneration() {
        print("🎭 HomeViewModel: Starting character generation")
        navigationRouter?.push(.characterGeneration)
    }
    
    func signOut() {
        print("🏠 HomeViewModel: Signing out")
        isLoading = true
        
        Task {
            do {
                try await authService.signOut()
                // AppRouter를 통해 로그인 화면으로 이동
                appRouter?.showLogin()
            } catch {
                print("❌ HomeViewModel: Sign out failed - \(error)")
            }
            
            isLoading = false
        }
    }
    

} 
