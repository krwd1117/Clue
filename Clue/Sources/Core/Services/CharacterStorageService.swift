//
//  CharacterStorageService.swift
//  Clue
//
//  Created by Assistant on 12/25/24.
//

import Foundation
import Supabase

@MainActor
class CharacterStorageService: ObservableObject {
    static let shared = CharacterStorageService()
    
    @Published var savedCharacters: [GeneratedCharacter] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let supabase: SupabaseClient
    
    private init() {
        self.supabase = SupabaseConfig.client
        print("🗄️ CharacterStorageService initialized")
    }
    
    // MARK: - 캐릭터 저장
    
    /// 새로 생성된 캐릭터를 데이터베이스에 저장
    func saveCharacter(_ character: GeneratedCharacter) async throws -> GeneratedCharacter {
        print("💾 Saving character: \(character.name)")
        
        guard AuthService.shared.isAuthenticated,
              let userId = AuthService.shared.currentUser?.id else {
            throw CharacterStorageError.notAuthenticated
        }
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            // 저장할 데이터 준비 (Codable을 사용하여 인코딩)
            struct CharacterInsertData: Codable {
                let id: String
                let user_id: String
                let name: String
                let age: String
                let appearance: String
                let backstory: String
                let conflict: String
                let model_used: String?
                let tokens_used: Int?
                let gender: String?
                let genre: String?
                let theme: String?
                let era: String?
                let mood: String?
                let personality: String?
                let origin: String?
                let weakness: String?
                let motivation: String?
                let goal: String?
                let twist: String?
            }
            
            let insertData = CharacterInsertData(
                id: character.id.uuidString,
                user_id: userId.uuidString,
                name: character.name,
                age: character.age,
                appearance: character.appearance,
                backstory: character.backstory,
                conflict: character.conflict,
                model_used: character.modelUsed,
                tokens_used: character.tokensUsed,
                gender: character.gender,
                genre: character.genre,
                theme: character.theme,
                era: character.era,
                mood: character.mood,
                personality: character.personality,
                origin: character.origin,
                weakness: character.weakness,
                motivation: character.motivation,
                goal: character.goal,
                twist: character.twist
            )
            
            // 데이터베이스에 저장
            let response: [GeneratedCharacter] = try await supabase
                .from("characters")
                .insert(insertData)
                .select()
                .execute()
                .value
            
            guard let savedCharacter = response.first else {
                throw CharacterStorageError.saveFailed("응답에서 저장된 캐릭터를 찾을 수 없습니다")
            }
            
            // 로컬 배열에 추가
            savedCharacters.insert(savedCharacter, at: 0)
            print("✅ Character saved successfully: \(savedCharacter.name)")
            
            return savedCharacter
            
        } catch {
            let errorMessage = "캐릭터 저장 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage)")
            self.error = errorMessage
            throw CharacterStorageError.saveFailed(errorMessage)
        }
    }
    
    // MARK: - 캐릭터 조회
    
    /// 현재 사용자의 모든 캐릭터 조회
    func loadUserCharacters() async throws {
        print("📖 Loading user characters...")
        
        guard AuthService.shared.isAuthenticated else {
            throw CharacterStorageError.notAuthenticated
        }
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let characters: [GeneratedCharacter] = try await supabase
                .from("characters")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            savedCharacters = characters
            print("✅ Loaded \(characters.count) characters")
            
        } catch {
            let errorMessage = "캐릭터 불러오기 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage)")
            self.error = errorMessage
            throw CharacterStorageError.loadFailed(errorMessage)
        }
    }
    
    /// 특정 캐릭터 조회
    func getCharacter(by id: UUID) async throws -> GeneratedCharacter? {
        print("🔍 Getting character: \(id)")
        
        guard AuthService.shared.isAuthenticated else {
            throw CharacterStorageError.notAuthenticated
        }
        
        do {
            let characters: [GeneratedCharacter] = try await supabase
                .from("characters")
                .select()
                .eq("id", value: id.uuidString)
                .execute()
                .value
            
            return characters.first
            
        } catch {
            print("❌ Failed to get character: \(error)")
            throw CharacterStorageError.loadFailed(error.localizedDescription)
        }
    }
    
    // MARK: - 캐릭터 삭제
    
    /// 캐릭터 삭제
    func deleteCharacter(_ character: GeneratedCharacter) async throws {
        print("🗑️ Deleting character: \(character.name)")
        
        guard AuthService.shared.isAuthenticated else {
            throw CharacterStorageError.notAuthenticated
        }
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            try await supabase
                .from("characters")
                .delete()
                .eq("id", value: character.id.uuidString)
                .execute()
            
            // 로컬 배열에서 제거
            savedCharacters.removeAll { $0.id == character.id }
            print("✅ Character deleted successfully: \(character.name)")
            
        } catch {
            let errorMessage = "캐릭터 삭제 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage)")
            self.error = errorMessage
            throw CharacterStorageError.deleteFailed(errorMessage)
        }
    }
    
    // MARK: - 캐릭터 업데이트
    
    /// 캐릭터 정보 업데이트
    func updateCharacter(_ character: GeneratedCharacter) async throws -> GeneratedCharacter {
        print("✏️ Updating character: \(character.name)")
        
        guard AuthService.shared.isAuthenticated else {
            throw CharacterStorageError.notAuthenticated
        }
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            // 업데이트할 데이터 준비 (Codable을 사용하여 인코딩)
            struct CharacterUpdateData: Codable {
                let name: String
                let age: String
                let appearance: String
                let backstory: String
                let conflict: String
                let model_used: String?
                let tokens_used: Int?
                let genre: String?
                let theme: String?
                let era: String?
                let mood: String?
                let personality: String?
                let origin: String?
                let weakness: String?
                let motivation: String?
                let goal: String?
                let twist: String?
            }
            
            let updateData = CharacterUpdateData(
                name: character.name,
                age: character.age,
                appearance: character.appearance,
                backstory: character.backstory,
                conflict: character.conflict,
                model_used: character.modelUsed,
                tokens_used: character.tokensUsed,
                genre: character.genre,
                theme: character.theme,
                era: character.era,
                mood: character.mood,
                personality: character.personality,
                origin: character.origin,
                weakness: character.weakness,
                motivation: character.motivation,
                goal: character.goal,
                twist: character.twist
            )
            
            let response: [GeneratedCharacter] = try await supabase
                .from("characters")
                .update(updateData)
                .eq("id", value: character.id.uuidString)
                .select()
                .execute()
                .value
            
            guard let updatedCharacter = response.first else {
                throw CharacterStorageError.updateFailed("응답에서 업데이트된 캐릭터를 찾을 수 없습니다")
            }
            
            // 로컬 배열 업데이트
            if let index = savedCharacters.firstIndex(where: { $0.id == character.id }) {
                savedCharacters[index] = updatedCharacter
            }
            
            print("✅ Character updated successfully: \(updatedCharacter.name)")
            return updatedCharacter
            
        } catch {
            let errorMessage = "캐릭터 업데이트 실패: \(error.localizedDescription)"
            print("❌ \(errorMessage)")
            self.error = errorMessage
            throw CharacterStorageError.updateFailed(errorMessage)
        }
    }
    
    // MARK: - 유틸리티 메서드
    
    /// 캐릭터가 이미 저장되어 있는지 확인
    func isCharacterSaved(_ character: GeneratedCharacter) -> Bool {
        return savedCharacters.contains { $0.id == character.id }
    }
    
    /// 저장된 캐릭터 수
    var charactersCount: Int {
        return savedCharacters.count
    }
    
    /// 에러 메시지 초기화
    func clearError() {
        error = nil
    }
}

// MARK: - 에러 타입
enum CharacterStorageError: LocalizedError {
    case notAuthenticated
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case updateFailed(String)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "로그인이 필요합니다"
        case .saveFailed(let message):
            return "저장 실패: \(message)"
        case .loadFailed(let message):
            return "불러오기 실패: \(message)"
        case .deleteFailed(let message):
            return "삭제 실패: \(message)"
        case .updateFailed(let message):
            return "업데이트 실패: \(message)"
        case .networkError:
            return "네트워크 연결을 확인해주세요"
        }
    }
} 
