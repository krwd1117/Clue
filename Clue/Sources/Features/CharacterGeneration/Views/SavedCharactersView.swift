//
//  SavedCharactersView.swift
//  Clue
//
//  Created by Assistant on 12/25/24.
//

import SwiftUI

// MARK: - 저장된 캐릭터 목록 뷰
struct SavedCharactersView: View {
    @StateObject private var storageService = CharacterStorageService.shared
    @StateObject private var authService = AuthService.shared
    @EnvironmentObject var navigationRouter: NavigationRouter
    
    @State private var showingDeleteConfirm = false
    @State private var characterToDelete: GeneratedCharacter?
    
    var body: some View {
            Group {
                if !authService.isAuthenticated {
                    // 로그인이 필요한 경우
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("로그인이 필요합니다")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("저장된 캐릭터를 보려면 로그인해주세요")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("로그인하기") {
                            // 로그인 화면으로 이동 (현재는 홈으로 돌아가기)
                            // TODO: 실제 로그인 화면 연결
                            navigationRouter.popToRoot()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                    
                } else if storageService.isLoading {
                    // 로딩 중
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("캐릭터를 불러오는 중...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                } else if storageService.savedCharacters.isEmpty {
                    // 저장된 캐릭터가 없는 경우
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.dashed")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("저장된 캐릭터가 없습니다")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("캐릭터를 생성하고 저장해보세요!")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("캐릭터 생성하기") {
                            navigationRouter.push(.characterGeneration)
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                    
                } else {
                    // 캐릭터 목록 (그리드 형태)
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(storageService.savedCharacters) { character in
                                SavedCharacterGridCard(
                                    character: character,
                                    onTap: {
                                        showCharacterDetail(character)
                                    },
                                    onDelete: {
                                        characterToDelete = character
                                        showingDeleteConfirm = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .refreshable {
                        await loadCharacters()
                    }
                }
            }
            .navigationTitle("내 캐릭터")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        navigationRouter.push(.characterGeneration)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        .onAppear {
            if authService.isAuthenticated {
                Task {
                    await loadCharacters()
                }
            }
        }
        .alert("캐릭터 삭제", isPresented: $showingDeleteConfirm) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                if let character = characterToDelete {
                    deleteCharacter(character)
                }
            }
        } message: {
            Text("이 캐릭터를 삭제하시겠습니까?")
        }
        .alert("오류", isPresented: .constant(storageService.error != nil)) {
            Button("확인") {
                storageService.clearError()
            }
        } message: {
            if let error = storageService.error {
                Text(error)
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadCharacters() async {
        do {
            try await storageService.loadUserCharacters()
        } catch {
            print("❌ Failed to load characters: \(error)")
        }
    }
    
    private func showCharacterDetail(_ character: GeneratedCharacter) {
        navigationRouter.push(.characterResult(character: character))
    }
    
    private func deleteCharacter(_ character: GeneratedCharacter) {
        Task {
            do {
                try await storageService.deleteCharacter(character)
            } catch {
                print("❌ Failed to delete character: \(error)")
            }
        }
    }
}

// MARK: - 저장된 캐릭터 카드 컴포넌트
struct SavedCharacterCard: View {
    let character: GeneratedCharacter
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 캐릭터 아바타
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(String(character.name.prefix(1)))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )
                
                // 캐릭터 정보
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(character.name)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(character.age)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(character.appearance)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(formattedDate(character.createdAt))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        if let tokensUsed = character.tokensUsed {
                            HStack(spacing: 4) {
                                Image(systemName: "cpu")
                                    .font(.system(size: 10))
                                Text("\(tokensUsed)")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // 삭제 버튼
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 그리드용 캐릭터 카드 컴포넌트
struct SavedCharacterGridCard: View {
    let character: GeneratedCharacter
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // 캐릭터 아바타
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(character.name.prefix(1)))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )
                
                // 캐릭터 정보
                VStack(spacing: 6) {
                    Text(character.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(character.age)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(character.appearance)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                    
                    // 메타 정보
                    HStack(spacing: 8) {
                        Text(formattedGridDate(character.createdAt))
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                        if let tokensUsed = character.tokensUsed {
                            HStack(spacing: 2) {
                                Image(systemName: "cpu")
                                    .font(.system(size: 8))
                                Text("\(tokensUsed)")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // 삭제 버튼
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(6)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .frame(height: 220)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formattedGridDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - 미리보기
#Preview {
    SavedCharactersView()
        .environmentObject(NavigationRouter())
} 
