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
            print("📤 캐릭터 목록 조회 시작...")
            
            let response: [Character] = try await client
                .from("characters")
                .select()
                .order("created_at", ascending: false) // 최신순 정렬
                .execute()
                .value
            
            print("✅ 캐릭터 목록 조회 성공: \(response.count)개")
            
            // 각 캐릭터의 기본 정보 로그
            for (index, character) in response.enumerated() {
                print("   [\(index + 1)] ID: \(character.id ?? -1), Name: \(character.name)")
                if let selectedOptions = character.selectedOptions {
                    print("       Selected Options: \(selectedOptions.count) items")
                } else {
                    print("       Selected Options: nil")
                }
            }
            
            return response
        } catch let decodingError as DecodingError {
            print("❌ 캐릭터 목록 디코딩 오류:")
            switch decodingError {
            case .dataCorrupted(let context):
                print("   - Data corrupted: \(context.debugDescription)")
                print("   - Coding path: \(context.codingPath)")
            case .keyNotFound(let key, let context):
                print("   - Key not found: \(key)")
                print("   - Context: \(context.debugDescription)")
                print("   - Coding path: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("   - Type mismatch: expected \(type)")
                print("   - Context: \(context.debugDescription)")
                print("   - Coding path: \(context.codingPath)")
            case .valueNotFound(let type, let context):
                print("   - Value not found: \(type)")
                print("   - Context: \(context.debugDescription)")
                print("   - Coding path: \(context.codingPath)")
            @unknown default:
                print("   - Unknown decoding error: \(decodingError)")
            }
            throw AppError.custom("캐릭터 데이터 형식이 올바르지 않습니다. 앱을 다시 시작해보세요.")
        } catch {
            print("❌ 캐릭터 목록 조회 실패: \(error)")
            
            // 네트워크 오류인지 확인
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    throw AppError.custom("인터넷 연결을 확인해주세요.")
                case .timedOut:
                    throw AppError.custom("요청 시간이 초과되었습니다. 다시 시도해주세요.")
                default:
                    throw AppError.custom("네트워크 오류가 발생했습니다.")
                }
            }
            
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