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
    @State private var profileVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 깔끔한 흰색 배경
                Color.white
                    .ignoresSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        // 사용자 프로필 섹션
                        if authService.isAuthenticated {
                            ProfileHeader(
                                user: authService.currentUser
                            )
                            .padding(.top, 20)
                            
                            // 통계 섹션
                            StatsSection(
                                charactersCount: storageService.charactersCount,
                                totalTokens: totalTokensUsed
                            )
                            
                            // 성취 섹션
                            AchievementSection(
                                charactersCount: storageService.charactersCount
                            )
                            
                            // 설정 섹션
                            SettingsSection(
                                showingLogoutConfirm: $showingLogoutConfirm
                            )
                            
                        } else {
                            // 로그인되지 않은 상태
                            LoginPrompt()
                                .padding(.top, 60)
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }
                .opacity(profileVisible ? 1 : 0)
                .offset(y: profileVisible ? 0 : 20)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert("로그아웃", isPresented: $showingLogoutConfirm) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                logout()
            }
        } message: {
            Text("정말 로그아웃하시겠습니까?")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
                profileVisible = true
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

// MARK: - 프로필 헤더
struct ProfileHeader: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 20) {
            // 프로필 이미지
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.crop.artframe")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.blue)
            }
            
            // 사용자 정보
            VStack(spacing: 8) {
                Text(user?.displayName ?? "사용자")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Text(user?.email ?? "")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - 통계 섹션
struct StatsSection: View {
    let charactersCount: Int
    let totalTokens: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("활동 통계")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "생성한 캐릭터",
                    value: "\(charactersCount)",
                    icon: "person.3.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "사용한 토큰",
                    value: "\(totalTokens)",
                    icon: "star.fill",
                    color: .orange
                )
            }
        }
    }
}

// MARK: - 성취 섹션
struct AchievementSection: View {
    let charactersCount: Int
    
    private var achievements: [Achievement] {
        [
            Achievement(
                title: "첫 걸음",
                description: "첫 번째 캐릭터 생성",
                icon: "star.fill",
                color: .yellow,
                isUnlocked: charactersCount >= 1
            ),
            Achievement(
                title: "열정적인 창작자",
                description: "5개 캐릭터 생성",
                icon: "flame.fill",
                color: .orange,
                isUnlocked: charactersCount >= 5
            ),
            Achievement(
                title: "마스터 창작자",
                description: "10개 캐릭터 생성",
                icon: "crown.fill",
                color: .purple,
                isUnlocked: charactersCount >= 10
            )
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("성취")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(achievements.indices, id: \.self) { index in
                    AchievementBadge(achievement: achievements[index])
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
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)
            }
            
            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(achievement.isUnlocked ? .black : .gray)
                
                Text(achievement.description)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(achievement.isUnlocked ? .gray : .gray.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(achievement.isUnlocked ? achievement.color.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - 설정 섹션
struct SettingsSection: View {
    @Binding var showingLogoutConfirm: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("설정")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                SettingRow(
                    icon: "rectangle.portrait.and.arrow.right.fill",
                    title: "로그아웃",
                    subtitle: "계정에서 로그아웃",
                    color: .red,
                    isDestructive: true,
                    action: {
                        showingLogoutConfirm = true
                    }
                )
            }
        }
    }
}

// MARK: - 설정 행
struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isDestructive: Bool
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String, color: Color, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isDestructive ? .red : .black)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - 로그인 프롬프트
struct LoginPrompt: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.crop.artframe")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("로그인이 필요합니다")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("프로필을 보려면 로그인해주세요")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - 미리보기
#Preview {
    ProfileView()
} 
