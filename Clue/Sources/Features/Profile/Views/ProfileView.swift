//
//  ProfileView.swift
//  Clue
//
//  Created by Assistant on 12/25/24.
//

import SwiftUI
import Supabase

// MARK: - 프로필 뷰
struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var storageService = CharacterStorageService.shared
    @State private var showingLogoutConfirm = false
    @State private var isAnimating = false
    @State private var profilePulse = false
    @State private var achievementVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 창작 테마 배경
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.05, blue: 0.3), // 깊은 보라
                        Color(red: 0.2, green: 0.1, blue: 0.4),  // 중간 보라
                        Color(red: 0.3, green: 0.2, blue: 0.5),  // 밝은 보라
                        Color(red: 0.4, green: 0.3, blue: 0.6)   // 연한 보라
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                // 떠다니는 창작 요소들
                ForEach(0..<6, id: \.self) { index in
                    FloatingProfileElement(index: index)
                        .opacity(0.15)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        // 사용자 프로필 섹션
                        if authService.isAuthenticated {
                            CreativeProfileHeader(
                                user: authService.currentUser,
                                profilePulse: $profilePulse
                            )
                            .padding(.top, 20)
                            
                            // 창작 통계 섹션
                            CreativeStatsSection(
                                charactersCount: storageService.charactersCount,
                                totalTokens: totalTokensUsed,
                                achievementVisible: $achievementVisible
                            )
                            
                            // 창작자 성취 섹션
                            CreativeAchievementSection(
                                charactersCount: storageService.charactersCount
                            )
                            
                            // 설정 섹션
                            CreativeSettingsSection(
                                showingLogoutConfirm: $showingLogoutConfirm
                            )
                            
                        } else {
                            // 로그인되지 않은 상태
                            CreativeLoginPrompt()
                                .padding(.top, 60)
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert("창작 여정 종료", isPresented: $showingLogoutConfirm) {
            Button("계속 창작하기", role: .cancel) { }
            Button("여정 종료", role: .destructive) {
                logout()
            }
        } message: {
            Text("정말 창작 여정을 마무리하시겠습니까?")
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                isAnimating = true
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                profilePulse = true
            }
            
            withAnimation(.easeInOut(duration: 0.8).delay(0.5)) {
                achievementVisible = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalTokensUsed: Int {
        return storageService.savedCharacters.compactMap { $0.tokensUsed }.reduce(0, +)
    }
    
    // MARK: - Actions
    
    private func logout() {
        Task {
            do {
                try await authService.signOut()
            } catch {
                print("❌ Logout failed: \(error)")
            }
        }
    }
}

// MARK: - 떠다니는 프로필 요소
struct FloatingProfileElement: View {
    let index: Int
    @State private var isMoving = false
    @State private var rotation: Double = 0
    
    private let symbols = ["person.crop.artframe", "paintbrush.pointed", "star.circle", "heart.circle", "trophy.circle", "crown"]
    private let colors: [Color] = [.cyan, .purple, .pink, .orange, .yellow, .mint]
    
    var body: some View {
        Image(systemName: symbols[index % symbols.count])
            .font(.system(size: CGFloat.random(in: 20...40), weight: .light))
            .foregroundColor(colors[index % colors.count])
            .opacity(0.7)
            .offset(
                x: isMoving ? CGFloat.random(in: -100...100) : CGFloat.random(in: -50...50),
                y: isMoving ? CGFloat.random(in: -200...200) : CGFloat.random(in: -100...100)
            )
            .rotationEffect(.degrees(rotation))
            .animation(
                .easeInOut(duration: Double.random(in: 5...9))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.4),
                value: isMoving
            )
            .animation(
                .linear(duration: Double.random(in: 15...25))
                .repeatForever(autoreverses: false)
                .delay(Double(index) * 0.3),
                value: rotation
            )
            .onAppear {
                isMoving = true
                rotation = 360
            }
    }
}

// MARK: - 창작자 프로필 헤더
struct CreativeProfileHeader: View {
    let user: User?
    @Binding var profilePulse: Bool
    
    var body: some View {
        VStack(spacing: 25) {
            // 프로필 이미지 및 장식
            ZStack {
                // 배경 원형 효과들
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.3),
                                Color.purple.opacity(0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(profilePulse ? 1.1 : 1.0)
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.pink.opacity(0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(profilePulse ? 0.9 : 1.0)
                
                // 메인 프로필 원
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.8),
                                Color.purple.opacity(0.9),
                                Color.pink.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.crop.artframe")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.white)
                    )
                    .shadow(color: .cyan.opacity(0.4), radius: 15)
            }
            
            // 사용자 정보
            VStack(spacing: 12) {
                Text(user?.displayName ?? "창작자")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .cyan.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(user?.email ?? "")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("✨ 상상력을 현실로 만드는 창작자 ✨")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.cyan.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - 창작 통계 섹션
struct CreativeStatsSection: View {
    let charactersCount: Int
    let totalTokens: Int
    @Binding var achievementVisible: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.cyan)
                
                Text("창작 통계")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                CreativeStatCard(
                    title: "생성한 캐릭터",
                    value: "\(charactersCount)",
                    icon: "person.3.fill",
                    colors: [.cyan, .blue],
                    delay: 0.0
                )
                
                CreativeStatCard(
                    title: "창작 경험치",
                    value: "\(totalTokens)",
                    icon: "star.fill",
                    colors: [.purple, .pink],
                    delay: 0.1
                )
            }
        }
        .opacity(achievementVisible ? 1 : 0)
        .offset(y: achievementVisible ? 0 : 20)
    }
}

// MARK: - 창작 통계 카드
struct CreativeStatCard: View {
    let title: String
    let value: String
    let icon: String
    let colors: [Color]
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: colors.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - 창작자 성취 섹션
struct CreativeAchievementSection: View {
    let charactersCount: Int
    
    private var achievements: [Achievement] {
        [
            Achievement(
                title: "첫 걸음",
                description: "첫 번째 캐릭터 창조",
                icon: "star.fill",
                color: .yellow,
                isUnlocked: charactersCount >= 1
            ),
            Achievement(
                title: "창작 열정",
                description: "5개 캐릭터 창조",
                icon: "flame.fill",
                color: .orange,
                isUnlocked: charactersCount >= 5
            ),
            Achievement(
                title: "마스터 창작자",
                description: "10개 캐릭터 창조",
                icon: "crown.fill",
                color: .purple,
                isUnlocked: charactersCount >= 10
            )
        ]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
                
                Text("창작 성취")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(achievements.indices, id: \.self) { index in
                    AchievementBadge(
                        achievement: achievements[index],
                        delay: Double(index) * 0.1
                    )
                }
            }
        }
    }
}

// MARK: - 성취 데이터 모델
struct Achievement {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
}

// MARK: - 성취 배지
struct AchievementBadge: View {
    let achievement: Achievement
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [achievement.color.opacity(0.3), achievement.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)
            }
            
            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                
                Text(achievement.description)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(achievement.isUnlocked ? .white.opacity(0.8) : .gray.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    achievement.isUnlocked ?
                    Color.white.opacity(0.05) :
                    Color.black.opacity(0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            achievement.isUnlocked ?
                            achievement.color.opacity(0.3) :
                            Color.gray.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - 창작 설정 섹션
struct CreativeSettingsSection: View {
    @Binding var showingLogoutConfirm: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.purple)
                
                Text("창작 도구")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                CreativeSettingRow(
                    icon: "bell.fill",
                    title: "알림 설정",
                    subtitle: "창작 영감 알림",
                    color: .cyan,
                    action: {
                        // TODO: 알림 설정 화면
                    }
                )
                
                CreativeSettingRow(
                    icon: "questionmark.circle.fill",
                    title: "창작 가이드",
                    subtitle: "도움말 및 팁",
                    color: .mint,
                    action: {
                        // TODO: 도움말 화면
                    }
                )
                
                CreativeSettingRow(
                    icon: "info.circle.fill",
                    title: "앱 정보",
                    subtitle: "버전 및 정보",
                    color: .orange,
                    action: {
                        // TODO: 앱 정보 화면
                    }
                )
                
                CreativeSettingRow(
                    icon: "rectangle.portrait.and.arrow.right.fill",
                    title: "창작 여정 종료",
                    subtitle: "로그아웃",
                    color: .pink,
                    isDestructive: true,
                    action: {
                        showingLogoutConfirm = true
                    }
                )
            }
        }
    }
}

// MARK: - 창작 설정 행
struct CreativeSettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isDestructive: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    init(icon: String, title: String, subtitle: String, color: Color, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isDestructive ? .pink : color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(isDestructive ? .pink : .white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(isDestructive ? .pink.opacity(0.7) : .white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                color.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}

// MARK: - 창작 로그인 프롬프트
struct CreativeLoginPrompt: View {
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.crop.artframe")
                    .font(.system(size: 60, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.8), .cyan.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("창작자 등록이 필요합니다")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("프로필을 보고 창작 여정을 시작하려면\n로그인해주세요")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text("✨ 상상력을 현실로 만들어보세요 ✨")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.cyan.opacity(0.8))
            }
        }
    }
}

// MARK: - 미리보기
#Preview {
    ProfileView()
} 
