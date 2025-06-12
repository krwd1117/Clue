//
//  ProfileView.swift
//  Clue
//
//  Created by Assistant on 12/25/24.
//

import SwiftUI

// MARK: - 프로필 뷰
struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var storageService = CharacterStorageService.shared
    @State private var showingLogoutConfirm = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 사용자 프로필 섹션
                    if authService.isAuthenticated {
                        VStack(spacing: 16) {
                            // 프로필 이미지
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                            
                            // 사용자 정보
                            VStack(spacing: 8) {
                                Text(authService.currentUser?.displayName ?? "사용자")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text(authService.currentUser?.email ?? "")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // 통계 섹션
                        VStack(spacing: 16) {
                            HStack {
                                Text("내 캐릭터 통계")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "생성한 캐릭터",
                                    value: "\(storageService.charactersCount)",
                                    icon: "person.3.fill",
                                    color: .blue
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 설정 섹션
                        VStack(spacing: 16) {
                            HStack {
                                Text("설정")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                SettingRow(
                                    icon: "bell.fill",
                                    title: "알림 설정",
                                    action: {
                                        // TODO: 알림 설정 화면
                                    }
                                )
                                
                                SettingRow(
                                    icon: "questionmark.circle.fill",
                                    title: "도움말",
                                    action: {
                                        // TODO: 도움말 화면
                                    }
                                )
                                
                                SettingRow(
                                    icon: "info.circle.fill",
                                    title: "앱 정보",
                                    action: {
                                        // TODO: 앱 정보 화면
                                    }
                                )
                                
                                SettingRow(
                                    icon: "rectangle.portrait.and.arrow.right.fill",
                                    title: "로그아웃",
                                    action: {
                                        showingLogoutConfirm = true
                                    },
                                    isDestructive: true
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                    } else {
                        // 로그인되지 않은 상태
                        VStack(spacing: 20) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                            
                            Text("로그인이 필요합니다")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("프로필을 보려면 로그인해주세요")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("로그아웃", isPresented: $showingLogoutConfirm) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                logout()
            }
        } message: {
            Text("정말 로그아웃하시겠습니까?")
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

// MARK: - 통계 카드 컴포넌트
//struct StatCard: View {
//    let title: String
//    let value: String
//    let icon: String
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: icon)
//                .font(.system(size: 24))
//                .foregroundColor(color)
//            
//            Text(value)
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(.primary)
//            
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 20)
//        .background(Color(.systemGray6))
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//    }
//}

// MARK: - 설정 행 컴포넌트
struct SettingRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    let isDestructive: Bool
    
    init(icon: String, title: String, action: @escaping () -> Void, isDestructive: Bool = false) {
        self.icon = icon
        self.title = title
        self.action = action
        self.isDestructive = isDestructive
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : .blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? .red : .primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 미리보기
#Preview {
    ProfileView()
} 
