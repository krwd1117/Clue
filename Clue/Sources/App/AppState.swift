import SwiftUI

enum AppFlow {
    case splash
    case login
    case main
}

@MainActor
class AppState: ObservableObject {
    @Published var currentFlow: AppFlow = .splash
    @Published var isCheckingSession = true
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        
        for family in UIFont.familyNames {
            print(family)
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  →", name)
            }
        }
    }
    
    func checkSession() async {
        isCheckingSession = true
        
        do {
            if let _ = try await authService.getSession() {
                currentFlow = .main
            } else {
                currentFlow = .login
            }
        } catch {
            print("Session check error: \(error)")
            currentFlow = .login
        }
        
        isCheckingSession = false
    }
    
    func signInCompleted() {
        currentFlow = .main
    }
    
    func signOut() {
        Task {
            do {
                try await authService.signOut()
                currentFlow = .login
            } catch {
                print("Sign out error: \(error)")
            }
        }
    }
} 
