import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://hvttiqbtwhvybozeeqlk.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2dHRpcWJ0d2h2eWJvemVlcWxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2MzE1NTYsImV4cCI6MjA2NTIwNzU1Nn0.socZ76ZQfIBUvyysM3NdEfsXU4v67Y9FL5P56Hh1EV8"
        )
    }
}
