//
//  CharacterResultView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

// MARK: - 캐릭터 결과 표시 뷰
struct CharacterResultView: View {
    let character: GeneratedCharacter
    let onDismiss: () -> Void
    
    @State private var showingShareSheet = false
    @State private var showingCopyAlert = false
    @State private var showingSaveAlert = false
    @State private var isSaving = false
    @State private var animationOffset: CGFloat = 50
    @State private var animationOpacity: Double = 0
    
    @StateObject private var storageService = CharacterStorageService.shared
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라디언트
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // 성공 헤더
                        VStack(spacing: 20) {
                            // 성공 애니메이션 아이콘
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.green.opacity(0.2), .blue.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50, weight: .medium))
                                    .foregroundStyle(.green)
                            }
                            .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 6)
                            
                            VStack(spacing: 8) {
                                Text("캐릭터 생성 완료!")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("새로운 캐릭터가 탄생했습니다")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // 캐릭터 프로필 카드
                        VStack(spacing: 24) {
                            // 캐릭터 아바타와 기본 정보
                            VStack(spacing: 16) {
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
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text(character.age)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.8))
                                        .clipShape(Capsule())
                                }
                            }
                            
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
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                        )
                        
                        // 액션 버튼들
                        VStack(spacing: 16) {
                            // 저장하기 (로그인된 경우에만 표시)
                            if authService.isAuthenticated {
                                Button(action: saveCharacter) {
                                    HStack(spacing: 12) {
                                        if isSaving {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                            Text("저장 중...")
                                        } else if isCharacterSaved {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18, weight: .medium))
                                            Text("저장 완료")
                                        } else {
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 18, weight: .medium))
                                            Text("내 컬렉션에 저장")
                                        }
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        LinearGradient(
                                            colors: isCharacterSaved ? 
                                                [.green, .green.opacity(0.8)] : 
                                                [.purple, .purple.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: (isCharacterSaved ? .green : .purple).opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .disabled(isSaving || isCharacterSaved)
                                .scaleEffect(isSaving ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: isSaving)
                            }
                            
                            HStack(spacing: 12) {
                                // 복사 버튼
                                Button(action: copyCharacter) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "doc.on.doc.fill")
                                            .font(.system(size: 20, weight: .medium))
                                        Text("복사")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(
                                        LinearGradient(
                                            colors: [.blue, .blue.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                
                                // 공유 버튼
                                Button(action: shareCharacter) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "square.and.arrow.up.fill")
                                            .font(.system(size: 20, weight: .medium))
                                        Text("공유")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(
                                        LinearGradient(
                                            colors: [.cyan, .cyan.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                            }
                            
                            // 새로 생성하기 버튼
                            Button(action: onDismiss) {
                                HStack(spacing: 12) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("새로 생성하기")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.orange)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.orange.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .offset(y: animationOffset)
                .opacity(animationOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                        animationOffset = 0
                        animationOpacity = 1
                    }
                }
            }
            .navigationTitle("생성 완료")
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
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [characterShareText])
        }
        .alert("복사 완료", isPresented: $showingCopyAlert) {
            Button("확인") { }
        } message: {
            Text("캐릭터 정보가 클립보드에 복사되었습니다.")
        }
        .alert("저장 완료", isPresented: $showingSaveAlert) {
            Button("확인") { }
        } message: {
            Text("캐릭터가 내 컬렉션에 저장되었습니다.")
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasGenerationSettings: Bool {
        character.genre != nil || character.theme != nil || character.era != nil ||
        character.mood != nil || character.personality != nil || character.origin != nil ||
        character.weakness != nil || character.motivation != nil || character.goal != nil || character.twist != nil
    }
    
    private var isCharacterSaved: Bool {
        return storageService.isCharacterSaved(character)
    }
    
    private var characterShareText: String {
        return """
        🎭 캐릭터 프로필
        
        📛 이름: \(character.name)
        🎂 나이: \(character.age)
        👤 외모: \(character.appearance)
        📖 배경: \(character.backstory)
        ⚡ 갈등: \(character.conflict)
        
        ---
        Clue 앱으로 생성된 캐릭터입니다
        """
    }
    
    // MARK: - Actions
    
    private func saveCharacter() {
        Task {
            isSaving = true
            
            do {
                _ = try await storageService.saveCharacter(character)
                showingSaveAlert = true
                print("💾 CharacterResultView: Character saved successfully")
            } catch {
                print("❌ CharacterResultView: Save failed - \(error)")
                // 에러는 StorageService에서 이미 처리됨
            }
            
            isSaving = false
        }
    }
    
    private func copyCharacter() {
        UIPasteboard.general.string = characterShareText
        showingCopyAlert = true
        print("📋 CharacterResultView: Character copied to clipboard")
    }
    
    private func shareCharacter() {
        showingShareSheet = true
        print("📤 CharacterResultView: Opening share sheet")
    }
}

// MARK: - 미리보기
#Preview {
    CharacterResultView(
        character: GeneratedCharacter(
            name: "리안느",
            age: "27세",
            appearance: "짙은 갈색 머리와 은빛 눈동자, 단단한 갑옷 차림",
            backstory: "왕국의 몰락한 기사 가문 출신으로, 잃어버린 명예를 되찾기 위해 여행 중",
            conflict: "과거 동료의 배신으로 믿음과 복수 사이에서 갈등"
        ),
        onDismiss: {}
    )
} 
