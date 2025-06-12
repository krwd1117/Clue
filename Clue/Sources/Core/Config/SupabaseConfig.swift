import Foundation
import Supabase

struct SupabaseConfig {
    // TODO: 실제 Supabase 프로젝트 설정으로 변경하세요
    static let supabaseURL = "https://hvttiqbtwhvybozeeqlk.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2dHRpcWJ0d2h2eWJvemVlcWxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2MzE1NTYsImV4cCI6MjA2NTIwNzU1Nn0.socZ76ZQfIBUvyysM3NdEfsXU4v67Y9FL5P56Hh1EV8"
    static let edgeFunctionURL = "https://hvttiqbtwhvybozeeqlk.supabase.co/functions/v1/generate-character"
    
    // OAuth Redirect URL
    static let redirectURL = "clue://oauth/callback"
    
    // 공유 Supabase 클라이언트 (싱글톤)
    static let client: SupabaseClient = {
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }()
}

// MARK: - 환경별 설정
extension SupabaseConfig {
    static var url: URL {
        guard let url = URL(string: supabaseURL) else {
            fatalError("Invalid Supabase URL: \(supabaseURL)")
        }
        return url
    }
    
    static var anonKey: String {
        return supabaseAnonKey
    }
} 
