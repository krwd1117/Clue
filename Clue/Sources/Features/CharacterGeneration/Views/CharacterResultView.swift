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
    @State private var celebrationScale: CGFloat = 0.5
    @State private var sparkleAnimating = false
    @State private var profilePulse = false
    
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
    
    private var saveButtonGradient: LinearGradient {
        if isCharacterSaved {
            return LinearGradient(
                colors: [.green, .green.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [.purple, .purple.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var saveButtonShadowColor: Color {
        return isCharacterSaved ? .green : .purple
    }
    
    private var backgroundGradient: LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.06, green: 0.03, blue: 0.2),  // 깊은 네이비
                Color(red: 0.12, green: 0.06, blue: 0.3),  // 미드나잇 블루
                Color(red: 0.2, green: 0.1, blue: 0.4),    // 깊은 보라
                Color(red: 0.3, green: 0.2, blue: 0.5)     // 중간 보라
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var successIconGradient: LinearGradient {
        return LinearGradient(
            colors: [.green.opacity(0.2), .blue.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var avatarGradient: LinearGradient {
        return LinearGradient(
            colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var copyButtonGradient: LinearGradient {
        return LinearGradient(
            colors: [.blue, .blue.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var shareButtonGradient: LinearGradient {
        return LinearGradient(
            colors: [.cyan, .cyan.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 창작 완료 배경
                backgroundGradient
                    .ignoresSafeArea(.all)
                
                // 떠다니는 축하 요소들
                ForEach(0..<12, id: \.self) { index in
                    FloatingCelebrationElement(index: index)
                        .opacity(0.3)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        // 창작 완료 헤더
                        CreationCompleteHeader(
                            celebrationScale: $celebrationScale,
                            sparkleAnimating: $sparkleAnimating
                        )
                        .padding(.top, 20)
                        
                        // 창작된 캐릭터 프로필
                        CreatedCharacterProfile(
                            character: character,
                            profilePulse: $profilePulse
                        )
                            
                        // 창작 정보 카드들
                        CreativeCharacterInfoCards(character: character)
                            
                        // 창작 설정 정보
                        if hasGenerationSettings {
                            CreationSettingsBadges(character: character)
                        }
                        
                        // 창작 완료 액션들
                        CreationCompleteActions(
                            character: character,
                            authService: authService,
                            storageService: storageService,
                            isCharacterSaved: isCharacterSaved,
                            isSaving: $isSaving,
                            showingSaveAlert: $showingSaveAlert,
                            showingCopyAlert: $showingCopyAlert,
                            showingShareSheet: $showingShareSheet,
                            characterShareText: characterShareText,
                            onDismiss: onDismiss
                        )
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
                    
                    withAnimation(.spring(response: 1.2, dampingFraction: 0.6).delay(0.3)) {
                        celebrationScale = 1.0
                    }
                    
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
                        sparkleAnimating = true
                    }
                    
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.8)) {
                        profilePulse = true
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

// MARK: - 떠다니는 축하 요소
struct FloatingCelebrationElement: View {
    let index: Int
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0.3
    
    var body: some View {
        let symbols = ["🎉", "✨", "🎊", "🌟", "🎭", "🎨", "👑", "⭐", "💫", "🔥", "🎪", "🏆"]
        
        Text(symbols[index % symbols.count])
            .font(.system(size: 16 + CGFloat(index % 4) * 4))
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                let delay = Double.random(in: 0...3)
                let duration = Double.random(in: 4...8)
                
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -40...40),
                        height: CGFloat.random(in: -50...50)
                    )
                    rotation = Double.random(in: -20...20)
                }
                
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    opacity = Double.random(in: 0.1...0.4)
                }
            }
    }
}

// MARK: - 창작 완료 헤더
struct CreationCompleteHeader: View {
    @Binding var celebrationScale: CGFloat
    @Binding var sparkleAnimating: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // 축하 아이콘
            ZStack {
                // 외부 축하 링
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.green.opacity(0.3),
                                Color.cyan.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(celebrationScale * 1.3)
                
                // 중간 축하 링
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.4),
                                Color.orange.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 25,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(celebrationScale * 1.2)
                
                // 메인 축하 아이콘
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green, Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .scaleEffect(celebrationScale)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 45, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(celebrationScale)
                
                // 반짝이는 효과
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "sparkle")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                        .offset(
                            x: cos(Double(index) * .pi / 4) * 60,
                            y: sin(Double(index) * .pi / 4) * 60
                        )
                        .opacity(sparkleAnimating ? 1.0 : 0.3)
                        .scaleEffect(sparkleAnimating ? 1.2 : 0.8)
                }
            }
            
            // 축하 메시지
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Text("🎉")
                        .font(.system(size: 28))
                    
                    Text("창작 완료!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("🌟")
                        .font(.system(size: 28))
                }
                
                VStack(spacing: 8) {
                    Text("새로운 캐릭터가 탄생했습니다")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("당신의 상상력이 현실이 되었어요! ✨")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 창작된 캐릭터 프로필
struct CreatedCharacterProfile: View {
    let character: GeneratedCharacter
    @Binding var profilePulse: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // 캐릭터 아바타
            ZStack {
                // 외부 펄스 링
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.pink.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(profilePulse ? 1.1 : 1.0)
                
                // 중간 링
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.cyan.opacity(0.4),
                                Color.blue.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 35,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(profilePulse ? 1.05 : 1.0)
                
                // 캐릭터 아바타
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.pink, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                Text(String(character.name.prefix(2)))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .textCase(.uppercase)
            }
            .shadow(color: .purple.opacity(0.4), radius: 20, x: 0, y: 10)
            
            // 캐릭터 기본 정보
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.artframe")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.cyan)
                    
                    Text(character.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text(character.age)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.purple.opacity(0.6), .pink.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 창작 캐릭터 정보 카드들
struct CreativeCharacterInfoCards: View {
    let character: GeneratedCharacter
    
    var body: some View {
        VStack(spacing: 20) {
            CreativeCharacterInfoCard(
                title: "외모",
                content: character.appearance,
                icon: "person.fill",
                gradient: [.purple, .pink],
                shadowColor: .purple
            )
            
            CreativeCharacterInfoCard(
                title: "배경 이야기",
                content: character.backstory,
                icon: "book.closed.fill",
                gradient: [.cyan, .blue],
                shadowColor: .cyan
            )
            
            CreativeCharacterInfoCard(
                title: "내적 갈등",
                content: character.conflict,
                icon: "bolt.heart.fill",
                gradient: [.orange, .red],
                shadowColor: .orange
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 창작 캐릭터 정보 카드
struct CreativeCharacterInfoCard: View {
    let title: String
    let content: String
    let icon: String
    let gradient: [Color]
    let shadowColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                // 아이콘
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(content)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.3) },
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: shadowColor.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

// MARK: - 창작 설정 배지들
struct CreationSettingsBadges: View {
    let character: GeneratedCharacter
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.yellow)
                    
                    Text("창작 설정")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                if let gender = character.gender {
                    CreativeSettingBadge(title: "성별", value: gender, gradient: [.mint, .teal])
                }
                if let genre = character.genre {
                    CreativeSettingBadge(title: "장르", value: genre, gradient: [.blue, .purple])
                }
                if let theme = character.theme {
                    CreativeSettingBadge(title: "테마", value: theme, gradient: [.purple, .pink])
                }
                if let era = character.era {
                    CreativeSettingBadge(title: "시대", value: era, gradient: [.orange, .red])
                }
                if let mood = character.mood {
                    CreativeSettingBadge(title: "분위기", value: mood, gradient: [.green, .cyan])
                }
                if let personality = character.personality {
                    CreativeSettingBadge(title: "성격", value: personality, gradient: [.pink, .orange])
                }
                if let origin = character.origin {
                    CreativeSettingBadge(title: "출신", value: origin, gradient: [.cyan, .blue])
                }
                if let weakness = character.weakness {
                    CreativeSettingBadge(title: "약점", value: weakness, gradient: [.red, .orange])
                }
                if let motivation = character.motivation {
                    CreativeSettingBadge(title: "동기", value: motivation, gradient: [.yellow, .orange])
                }
                if let goal = character.goal {
                    CreativeSettingBadge(title: "목표", value: goal, gradient: [.indigo, .blue])
                }
                if let twist = character.twist {
                    CreativeSettingBadge(title: "반전", value: twist, gradient: [.brown, .orange])
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 창작 설정 배지
struct CreativeSettingBadge: View {
    let title: String
    let value: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: gradient.map { $0.opacity(0.2) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.4) },
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - 창작 완료 액션들
struct CreationCompleteActions: View {
    let character: GeneratedCharacter
    let authService: AuthService
    let storageService: CharacterStorageService
    let isCharacterSaved: Bool
    @Binding var isSaving: Bool
    @Binding var showingSaveAlert: Bool
    @Binding var showingCopyAlert: Bool
    @Binding var showingShareSheet: Bool
    let characterShareText: String
    let onDismiss: () -> Void
    
    private func saveCharacter() {
        Task {
            isSaving = true
            
            do {
                _ = try await storageService.saveCharacter(character)
                showingSaveAlert = true
            } catch {
                print("❌ CreationCompleteActions: Save failed - \(error)")
            }
            
            isSaving = false
        }
    }
    
    private func copyCharacter() {
        UIPasteboard.general.string = characterShareText
        showingCopyAlert = true
    }
    
    private func shareCharacter() {
        showingShareSheet = true
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // 저장하기 (로그인된 경우에만)
            if authService.isAuthenticated {
                Button(action: saveCharacter) {
                    HStack(spacing: 12) {
                        if isSaving {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    .frame(width: 20, height: 20)
                                
                                Circle()
                                    .trim(from: 0, to: 0.7)
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
                            }
                            
                            Text("컬렉션에 저장 중...")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        } else if isCharacterSaved {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("저장 완료")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        } else {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("내 컬렉션에 저장")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        Group {
                            if isCharacterSaved {
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(
                        color: isCharacterSaved ? .green.opacity(0.4) : .purple.opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .disabled(isSaving || isCharacterSaved)
                .scaleEffect(isSaving ? 0.98 : 1.0)
            }
            
            // 공유 액션들
            HStack(spacing: 16) {
                // 복사 버튼
                Button(action: copyCharacter) {
                    VStack(spacing: 10) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 24, weight: .medium))
                        
                        Text("복사")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .background(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .cyan.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                
                // 공유 버튼
                Button(action: shareCharacter) {
                    VStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.system(size: 24, weight: .medium))
                        
                        Text("공유")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .orange.opacity(0.4), radius: 12, x: 0, y: 6)
                }
            }
            
            // 새로 창작하기 버튼
            Button(action: onDismiss) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text("새로운 캐릭터 창작하기")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
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
