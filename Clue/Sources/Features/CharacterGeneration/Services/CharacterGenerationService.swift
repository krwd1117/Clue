import Foundation
import Supabase

protocol CharacterGenerationServiceProtocol {
    func fetchCategories() async throws -> [CharacterCategory]
    func fetchOptions(for categoryId: Int) async throws -> [CharacterOption]
    func createCharacter(_ request: CharacterCreateRequest) async throws -> Character
}

class CharacterGenerationService: CharacterGenerationServiceProtocol {
    static let shared = CharacterGenerationService()
    private let client = SupabaseService.shared.client
    
    private init() {}
    
    func fetchCategories() async throws -> [CharacterCategory] {
        do {
            let response: [CharacterCategory] = try await client
                .from("character_category")
                .select()
                .order("id")
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.network(error)
        }
    }
    
    func fetchOptions(for categoryId: Int) async throws -> [CharacterOption] {
        do {
            let response: [CharacterOption] = try await client
                .from("character_option")
                .select()
                .eq("category_id", value: categoryId)
                .order("id")
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.network(error)
        }
    }
    
    func createCharacter(_ request: CharacterCreateRequest) async throws -> Character {
        do {
            let response: Character = try await client
                .from("character")
                .insert(request)
                .select()
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.network(error)
        }
    }
} 