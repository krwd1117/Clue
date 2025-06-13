import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Profile header
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Profile image
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.primary.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text("사용자")
                                .font(DesignSystem.Typography.title)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Clue 크리에이터")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    
                    // Stats section
                    HStack(spacing: DesignSystem.Spacing.xl) {
                        StatItem(title: "캐릭터", count: "12")
                        StatItem(title: "시나리오", count: "8")
                        StatItem(title: "스토리", count: "24")
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    // Menu sections
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Account section
                        TossMenuSection(
                            title: "계정",
                            items: [
                                .init(
                                    icon: "person.circle",
                                    title: "프로필 편집"
                                ) {
                                    // TODO: Navigate to profile edit
                                },
                                .init(
                                    icon: "bell",
                                    title: "알림 설정"
                                ) {
                                    // TODO: Navigate to notification settings
                                }
                            ]
                        )
                        
                        // App section
                        TossMenuSection(
                            title: "앱",
                            items: [
                                .init(
                                    icon: "questionmark.circle",
                                    title: "도움말"
                                ) {
                                    // TODO: Navigate to help
                                },
                                .init(
                                    icon: "doc.text",
                                    title: "이용약관"
                                ) {
                                    // TODO: Navigate to terms
                                },
                                .init(
                                    icon: "hand.raised",
                                    title: "개인정보처리방침"
                                ) {
                                    // TODO: Navigate to privacy policy
                                }
                            ]
                        )
                        
                        // Sign out section
                        TossMenuSection(
                            items: [
                                .init(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    title: "로그아웃",
                                    titleColor: DesignSystem.Colors.accent,
                                    showChevron: false
                                ) {
                                    showSignOutAlert = true
                                }
                            ]
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    Spacer(minLength: DesignSystem.Spacing.xl)
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("로그아웃", isPresented: $showSignOutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                appState.signOut()
            }
        } message: {
            Text("정말 로그아웃하시겠습니까?")
        }
    }
}

struct StatItem: View {
    let title: String
    let count: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(count)
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.primary)
                .fontWeight(.bold)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}



#Preview {
    ProfileView()
        .environmentObject(AppState())
} 