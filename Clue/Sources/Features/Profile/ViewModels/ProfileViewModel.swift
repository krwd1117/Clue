//
//  ProfileViewModel.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var characterCount: Int = 0
    @Published var isLoading = false
    @Published var error: AppError?
    
    private let characterService: CharacterLibraryServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        characterService: CharacterLibraryServiceProtocol = CharacterLibraryService.shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        self.characterService = characterService
        self.authService = authService
    }
    
    func loadUserStats() async {
        isLoading = true
        error = nil
        
        do {
            let characters = try await characterService.fetchUserCharacters()
            characterCount = characters.count
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = AppError.network(error)
        }
        
        isLoading = false
    }
    
    func deleteAccount() async throws {
        try await authService.deleteAccount()
    }
} 