//
//  MainTabViewModel.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import Foundation
import SwiftUI

@MainActor
class MainTabViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    
    private let authService = AuthService.shared
    
    // MARK: - Setup
    
    func setup() {
        print("🏠 MainTabViewModel: Setting up main tab view")
        // 메인 화면 초기화 로직
    }
    
    // MARK: - Tab Management
    
    func selectTab(_ index: Int) {
        print("🏠 MainTabViewModel: Selecting tab \(index)")
        selectedTab = index
    }
    
    // MARK: - User Information
    
//    var currentUser: User? {
//        authService.currentUser
//    }
    
    var isAuthenticated: Bool {
        authService.isAuthenticated
    }
} 
