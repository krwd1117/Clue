//
//  CharacterDetailModalView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

// MARK: - 캐릭터 상세 모달 뷰
struct CharacterDetailModalView: View {
    let character: GeneratedCharacter
    let onDismiss: () -> Void
    
    @State private var showingShareSheet = false
    @State private var showingCopyAlert = false
    @StateObject private var storageService = CharacterStorageService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더 섹션
                    VStack(spacing: 16) {
                        // 캐릭터 아바타
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Text(String(character.name.prefix(2)))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                        }
                        .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
                        
                        VStack(spacing: 8) {
                            Text(character.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(character.age)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.8))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 20)
                    
                    // 캐릭터 정보 카드들
                    VStack(spacing: 16) {
                        CharacterInfoCard(
                            title: "외모",
                            content: character.appearance,
                            icon: "person.fill",
                            color: .blue
                        )
                        
                        CharacterInfoCard(
                            title: "배경 이야기",
                            content: character.backstory,
                            icon: "book.fill",
                            color: .green
                        )
                        
                        CharacterInfoCard(
                            title: "갈등",
                            content: character.conflict,
                            icon: "exclamationmark.triangle.fill",
                            color: .orange
                        )
                    }
                    
                    // 생성 설정 정보 (설정값이 있는 경우에만 표시)
                    if hasGenerationSettings {
                        VStack(spacing: 12) {
                            HStack {
                                Text("생성 설정")
                                    .font(.system(size: 18, weight: .semibold))
                                Spacer()
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                if let genre = character.genre {
                                    SettingBadge(title: "장르", value: genre, color: .blue)
                                }
                                if let theme = character.theme {
                                    SettingBadge(title: "테마", value: theme, color: .purple)
                                }
                                if let era = character.era {
                                    SettingBadge(title: "시대", value: era, color: .orange)
                                }
                                if let mood = character.mood {
                                    SettingBadge(title: "분위기", value: mood, color: .green)
                                }
                                if let personality = character.personality {
                                    SettingBadge(title: "성격", value: personality, color: .pink)
                                }
                                if let origin = character.origin {
                                    SettingBadge(title: "출신", value: origin, color: .cyan)
                                }
                                if let weakness = character.weakness {
                                    SettingBadge(title: "약점", value: weakness, color: .red)
                                }
                                if let motivation = character.motivation {
                                    SettingBadge(title: "동기", value: motivation, color: .yellow)
                                }
                                if let goal = character.goal {
                                    SettingBadge(title: "목표", value: goal, color: .indigo)
                                }
                                if let twist = character.twist {
                                    SettingBadge(title: "반전", value: twist, color: .brown)
                                }
                            }
                        }
                    }
                    
                    // 메타 정보
                    VStack(spacing: 12) {
                        HStack {
                            Text("생성 정보")
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                        }
                        
                        VStack(spacing: 8) {
                            MetaInfoRow(
                                icon: "calendar",
                                title: "생성일",
                                value: formattedCreationDate(character.createdAt)
                            )
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // 액션 버튼들
                    VStack(spacing: 12) {
                        // 복사 버튼
                        Button(action: copyCharacterInfo) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("클립보드에 복사")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // 공유 버튼
                        Button(action: shareCharacter) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("공유하기")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("캐릭터 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        onDismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .onAppear {
            print("🎭 CharacterDetailModalView appeared with character: \(character.name)")
        }
        .alert("복사 완료", isPresented: $showingCopyAlert) {
            Button("확인") { }
        } message: {
            Text("캐릭터 정보가 클립보드에 복사되었습니다.")
        }
        .sheet(isPresented: $showingShareSheet) {
            ActivityViewController(activityItems: [createShareText()])
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasGenerationSettings: Bool {
        character.genre != nil || character.theme != nil || character.era != nil ||
        character.mood != nil || character.personality != nil || character.origin != nil ||
        character.weakness != nil || character.motivation != nil || character.goal != nil || character.twist != nil
    }
    
    // MARK: - Helper Functions
    
    private func formattedCreationDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func createShareText() -> String {
        return """
        🎭 캐릭터: \(character.name)
        📅 나이: \(character.age)
        
        👤 외모:
        \(character.appearance)
        
        📖 배경 이야기:
        \(character.backstory)
        
        ⚡ 갈등:
        \(character.conflict)
        
        생성일: \(formattedCreationDate(character.createdAt))
        """
    }
    
    private func copyCharacterInfo() {
        UIPasteboard.general.string = createShareText()
        showingCopyAlert = true
    }
    
    private func shareCharacter() {
        showingShareSheet = true
    }
}
