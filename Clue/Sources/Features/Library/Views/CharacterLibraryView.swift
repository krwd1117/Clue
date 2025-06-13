//
//  CharacterLibraryView.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

struct CharacterLibraryView: View {
    @StateObject private var viewModel = CharacterLibraryViewModel()
    @State private var selectedCharacter: Character?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Grid container with proper spacing
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ], spacing: 24) {
                    // Character cards
                    ForEach(viewModel.characters, id: \.id) { character in
                        CharacterCard(
                            character: character,
                            onTap: {
                                selectedCharacter = character
                            },
                            onDelete: {
                                viewModel.deleteCharacter(character)
                            }
                        )
                        .id("character-\(character.id ?? 0)") // Unique ID for each card
                        .clipped() // Prevent shadow overflow
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            
                // Empty state
                if viewModel.isEmpty {
                    VStack(spacing: 24) {
                        // Illustration
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.95, green: 0.95, blue: 0.97),
                                            Color(red: 0.98, green: 0.98, blue: 0.99)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "person.3.sequence")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        }
                        
                        // Text content
                        VStack(spacing: 8) {
                            Text("아직 생성된 캐릭터가 없어요")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                            
                            Text("첫 번째 캐릭터를 만들어\n나만의 스토리를 시작해보세요!")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                }
                
                // Loading state
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        // Custom loading animation
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 3)
                                .frame(width: 40, height: 40)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.0, green: 0.4, blue: 1.0),
                                            Color(red: 0.2, green: 0.6, blue: 1.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                )
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
                        }
                        
                        Text("캐릭터를 불러오는 중...")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                }
            }
        }
        .clipped() // Prevent any overflow
        .refreshable {
            await viewModel.loadCharacters()
        }
        .task {
            await viewModel.loadCharacters()
        }
        .sheet(item: $selectedCharacter) { character in
            CharacterDetailView(character: character) {
                // 캐릭터 삭제 완료 후 목록 새로고침
                Task {
                    await viewModel.loadCharacters()
                }
            }
        }
        .alert("캐릭터 삭제", isPresented: $viewModel.showingDeleteAlert) {
            Button("취소", role: .cancel) {
                viewModel.cancelDelete()
            }
            
            Button("삭제", role: .destructive) {
                Task {
                    await viewModel.confirmDelete()
                }
            }
        } message: {
            if let character = viewModel.characterToDelete {
                Text("'\(character.name)' 캐릭터를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.")
            }
        }
        .alert("오류", isPresented: .constant(viewModel.error != nil)) {
            Button("확인") {
                viewModel.error = nil
            }
            Button("다시 시도") {
                Task {
                    await viewModel.loadCharacters()
                }
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}
