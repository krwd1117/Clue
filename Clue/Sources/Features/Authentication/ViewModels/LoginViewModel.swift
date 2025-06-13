import SwiftUI
import Supabase

@MainActor
class LoginViewModel: ObservableObject {
    @Published var error: AppError?
    @Published var isLoading = false
    @Published var isAppleLoading = false
    @Published var isGoogleLoading = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    func signInWithApple() async {
        isAppleLoading = true
        isLoading = true
        
        do {
            let session = try await authService.signInWith(provider: .apple)
            print("Successfully signed in with Apple: \(session)")
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.authentication(error)
        }
        
        isAppleLoading = false
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isGoogleLoading = true
        isLoading = true
        
        do {
            let session = try await authService.signInWith(provider: .google)
            print("Successfully signed in with Google: \(session)")
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.authentication(error)
        }
        
        isGoogleLoading = false
        isLoading = false
    }
}
