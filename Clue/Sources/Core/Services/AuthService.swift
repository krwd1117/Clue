import Foundation
import Supabase

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    private let supabase: SupabaseClient
    
    private init() {
        // 공유 Supabase 클라이언트 사용
        self.supabase = SupabaseConfig.client
        
        print("🔧 AuthService initialized with URL: \(SupabaseConfig.supabaseURL)")
        
        // Auth state 변경 리스너 추가
        setupAuthStateListener()
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthStateListener() {
        Task {
            for await state in supabase.auth.authStateChanges {
                print("🔄 Auth state changed: \(state.event)")
                await handleAuthStateChange(state)
            }
        }
    }
    
    private func handleAuthStateChange(_ state: (event: AuthChangeEvent, session: Session?)) async {
        switch state.event {
        case .signedIn:
            print("✅ User signed in")
            currentUser = state.session?.user
            isAuthenticated = true
        case .signedOut:
            print("👋 User signed out")
            currentUser = nil
            isAuthenticated = false
        case .tokenRefreshed:
            print("🔄 Token refreshed")
            currentUser = state.session?.user
            isAuthenticated = state.session != nil
        default:
            print("ℹ️ Auth state: \(state.event)")
        }
    }
    
    // MARK: - OAuth 로그인 메서드들
    
    /// Google OAuth 로그인
    func signInWithGoogle() async throws {
        print("🚀 Starting Google OAuth login...")
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: SupabaseConfig.redirectURL)
            )
            print("✅ Google OAuth request sent successfully")
        } catch {
            print("❌ Google OAuth error: \(error)")
            throw error
        }
    }
    
    /// Apple OAuth 로그인
    func signInWithApple() async throws {
        print("🚀 Starting Apple OAuth login...")
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await supabase.auth.signInWithOAuth(
                provider: .apple,
                redirectTo: URL(string: SupabaseConfig.redirectURL)
            )
            print("✅ Apple OAuth request sent successfully")
        } catch {
            print("❌ Apple OAuth error: \(error)")
            throw error
        }
    }
    
    // MARK: - 세션 관리
    
    /// 현재 세션 확인
    func checkCurrentSession() async {
        print("🔍 Checking current session...")
        do {
            let session = try await supabase.auth.session
            print("✅ Session found: \(session.user.email ?? "no email")")
            currentUser = session.user
            isAuthenticated = true
            print("🎉 User authenticated successfully!")
        } catch {
            print("⚠️ No active session: \(error)")
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    /// 세션 새로고침
    func refreshSession() async {
        print("🔄 Refreshing session...")
        do {
            let session = try await supabase.auth.refreshSession()
            print("✅ Session refreshed: \(session.user.email ?? "no email")")
            currentUser = session.user
            isAuthenticated = true
        } catch {
            print("❌ Failed to refresh session: \(error)")
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    /// 로그아웃
    func signOut() async throws {
        print("👋 Signing out...")
        isLoading = true
        defer {
            isLoading = false
        }
        
        try await supabase.auth.signOut()
        currentUser = nil
        isAuthenticated = false
        print("✅ Successfully signed out")
    }
    
    /// OAuth Callback 처리
    func handleOAuthCallback(url: URL) async {
        print("🔗 Handling OAuth callback: \(url)")
        print("🔗 URL Query Items: \(url.query ?? "none")")
        
        // URL 유효성 검증 (향상된 검증)
        guard SupabaseConfig.validateURLScheme(url) else {
            print("❌ Invalid URL scheme: \(url.scheme ?? "none")")
            return
        }
        
        do {
            // URL에서 세션 생성
            try await supabase.auth.session(from: url)
            print("✅ Session created from callback URL")
            
            // 조금 기다린 후 세션 상태 확인 (네트워크 지연 고려)
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5초
            await checkCurrentSession()
            
            // 추가로 세션 새로고침 시도
            if !isAuthenticated {
                print("🔄 Trying to refresh session...")
                await refreshSession()
            }
            
            print("🔄 Final authentication state: \(isAuthenticated)")
        } catch {
            print("❌ OAuth callback error: \(error)")
            
            // 추가적인 에러 정보 출력
            if let supabaseError = error as? AuthError {
                print("📋 Supabase Auth Error Details: \(supabaseError)")
            }
            
            // URL 파싱 문제일 수 있으므로 수동으로 파라미터 확인
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                print("📋 URL Components: \(components)")
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        print("  - \(item.name): \(item.value ?? "nil")")
                    }
                }
            }
            
            // 콜백 실패 시에도 세션 확인 시도
            print("🔄 Callback failed, checking session anyway...")
            await checkCurrentSession()
        }
    }
}

// MARK: - User Model Extension
extension User {
    var displayName: String {
        userMetadata["full_name"]?.stringValue ?? 
        userMetadata["name"]?.stringValue ?? 
        email ?? "User"
    }
    
    var avatarURL: String? {
        userMetadata["avatar_url"]?.stringValue ??
        userMetadata["picture"]?.stringValue
    }
} 