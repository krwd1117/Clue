import Foundation
import Supabase

protocol AuthServiceProtocol {
    func signInWith(provider: Provider) async throws -> Session
    func signOut() async throws
    func getSession() async throws -> Session?
}

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private let client = SupabaseService.shared.client
    
    private init() {}
    
    func signInWith(provider: Provider) async throws -> Session {
        do {
            return try await client.auth.signInWithOAuth(provider: provider, redirectTo: URL(string: "clue://oauth/callback"))
        } catch {
            throw AppError.authentication(error)
        }
    }
    
    func signOut() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            throw AppError.authentication(error)
        }
    }
    
    func getSession() async throws -> Session? {
        do {
            return try await client.auth.session
        } catch {
            throw AppError.authentication(error)
        }
    }
} 
