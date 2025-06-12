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
    @State private var animationOffset: CGFloat = 30
    @State private var animationOpacity: Double = 0
    @State private var celebrationScale: CGFloat = 0.8
    
    @StateObject private var storageService = CharacterStorageService.shared
    @StateObject private var authService = AuthService.shared
    
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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 깔끔한 흰색 배경
                Color.white
                    .ignoresSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        // 성공 헤더
                        VStack(spacing: 24) {
                            // 성공 아이콘
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            .scaleEffect(celebrationScale)
                            
                            // 성공 메시지
                            VStack(spacing: 12) {
                                Text("캐릭터 생성 완료!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("새로운 캐릭터가 탄생했습니다")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 40)
                        
                        // 캐릭터 프로필 카드
                        VStack(spacing: 20) {
                            // 캐릭터 아바타
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Text(String(character.name.prefix(2)))
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.blue)
                                    .textCase(.uppercase)
                            }
                            
                            // 기본 정보
                            VStack(spacing: 8) {
                                Text(character.name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text(character.age)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
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
                                icon: "book.closed.fill",
                                color: .green
                            )
                            
                            CharacterInfoCard(
                                title: "내적 갈등",
                                content: character.conflict,
                                icon: "bolt.heart.fill",
                                color: .orange
                            )
                        }
                        
                        // 생성 설정 정보
                        if hasGenerationSettings {
                            VStack(spacing: 16) {
                                HStack {
                                    Text("생성 설정")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ], spacing: 12) {
                                    if let gender = character.gender {
                                        SettingBadge(title: "성별", value: gender, color: .mint)
                                    }
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
                            .padding(20)
                            .background(Color.gray.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // 액션 버튼들
                        VStack(spacing: 16) {
                            // 저장하기 (로그인된 경우에만)
                            if authService.isAuthenticated {
                                Button(action: saveCharacter) {
                                    HStack(spacing: 12) {
                                        if isSaving {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .tint(.white)
                                            
                                            Text("저장 중...")
                                                .font(.system(size: 16, weight: .semibold))
                                        } else if isCharacterSaved {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18, weight: .medium))
                                            
                                            Text("저장 완료")
                                                .font(.system(size: 16, weight: .semibold))
                                        } else {
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 18, weight: .medium))
                                            
                                            Text("내 컬렉션에 저장")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(isCharacterSaved ? Color.green : Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                                .disabled(isSaving || isCharacterSaved)
                            }
                            
                            // 공유 액션들
                            HStack(spacing: 12) {
                                // 복사 버튼
                                Button(action: copyCharacter) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "doc.on.doc.fill")
                                            .font(.system(size: 20, weight: .medium))
                                        
                                        Text("복사")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                // 공유 버튼
                                Button(action: shareCharacter) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "square.and.arrow.up.fill")
                                            .font(.system(size: 20, weight: .medium))
                                        
                                        Text("공유")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.green)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Color.green.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            
                            // 새로 생성하기 버튼
                            Button(action: onDismiss) {
                                HStack(spacing: 12) {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    Text("새로운 캐릭터 생성하기")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .offset(y: animationOffset)
                .opacity(animationOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        animationOffset = 0
                        animationOpacity = 1
                    }
                    
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                        celebrationScale = 1.0
                    }
                }
            }
            .navigationBarHidden(true)
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
}
