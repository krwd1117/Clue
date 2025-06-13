//
//  CharacterLibraryService.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import Foundation
import Supabase

protocol CharacterLibraryServiceProtocol {
    func fetchUserCharacters() async throws -> [Character]
    func deleteCharacter(id: Int) async throws
}

class CharacterLibraryService: CharacterLibraryServiceProtocol {
    static let shared = CharacterLibraryService()
    
    private let client = SupabaseService.shared.client
    
    private init() {}
    
    func fetchUserCharacters() async throws -> [Character] {
        do {
            let response: [Character] = try await client
                .from("characters")
                .select()
                .order("created_at", ascending: false) // 최신순 정렬
                .execute()
                .value
            
            print("✅ 캐릭터 목록 조회 성공: \(response.count)개")
            return response
        } catch {
            print("❌ 캐릭터 목록 조회 실패: \(error)")
            throw AppError.network(error)
        }
    }
    
    func deleteCharacter(id: Int) async throws {
        do {
            try await client
                .from("characters")
                .delete()
                .eq("id", value: id)
                .execute()
            
            print("✅ 캐릭터 삭제 성공: ID \(id)")
        } catch {
            print("❌ 캐릭터 삭제 실패: \(error)")
            throw AppError.network(error)
        }
    }
} 