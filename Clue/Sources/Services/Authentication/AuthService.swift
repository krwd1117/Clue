import Foundation
import Supabase

protocol AuthServiceProtocol {
    func signInWith(provider: Provider) async throws -> Session
    func signOut() async throws
    func getSession() async throws -> Session?
    func deleteAccount() async throws
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
    
    func deleteAccount() async throws {
        do {
            // 1. 사용자의 모든 캐릭터 데이터 삭제
            try await client
                .from("characters")
                .delete()
                .execute()
            
            // 2. Supabase Auth에서 사용자 계정 삭제
            // 현재 Supabase Swift SDK에서는 직접적인 계정 삭제 API가 제한적이므로
            // 서버 사이드에서 처리하거나 관리자 API를 사용해야 합니다.
            // 임시로 로그아웃 처리
            try await signOut()
        } catch {
            throw AppError.authentication(error)
        }
    }
} 
