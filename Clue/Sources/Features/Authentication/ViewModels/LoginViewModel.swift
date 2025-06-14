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
    
    func signInWithOAuth(provier: Provider) async {
        if provier == .apple {
            isAppleLoading = true
        } else if provier == .google {
            isGoogleLoading = true
        }
        
        isLoading = true
        
        do {
            let session = try await authService.signInWith(provider: provier)
            print("Successfully signed in: \(session)")
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.authentication(error)
        }
        
        if provier == .apple {
            isAppleLoading = false
        } else if provier == .google {
            isGoogleLoading = false
        }
        
        isLoading = false
    }
}
