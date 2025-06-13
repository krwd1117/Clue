//
//  CharacterLibraryViewModel.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import Foundation
import SwiftUI

@MainActor
class CharacterLibraryViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var showingDeleteAlert = false
    @Published var characterToDelete: Character?
    
    private let service: CharacterLibraryServiceProtocol
    
    init(service: CharacterLibraryServiceProtocol = CharacterLibraryService.shared) {
        self.service = service
    }
    
    func loadCharacters() async {
        isLoading = true
        error = nil
        
        do {
            characters = try await service.fetchUserCharacters()
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.network(error)
        }
        
        isLoading = false
    }
    
    func deleteCharacter(_ character: Character) {
        characterToDelete = character
        showingDeleteAlert = true
    }
    
    func confirmDelete() async {
        guard let character = characterToDelete,
              let characterId = character.id else {
            return
        }
        
        do {
            try await service.deleteCharacter(id: characterId)
            
            // 로컬 배열에서도 제거
            characters.removeAll { $0.id == characterId }
            
            characterToDelete = nil
            showingDeleteAlert = false
            
            print("✅ 캐릭터 삭제 완료 및 목록 업데이트: \(character.name)")
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.network(error)
        }
    }
    
    func cancelDelete() {
        characterToDelete = nil
        showingDeleteAlert = false
    }
    
    var hasCharacters: Bool {
        !characters.isEmpty
    }
    
    var isEmpty: Bool {
        !isLoading && characters.isEmpty
    }
} 