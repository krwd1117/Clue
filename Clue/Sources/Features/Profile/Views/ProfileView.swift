import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section
//                heroSection
                
                // Stats Section
                statsSection
                
                // Menu Sections
                menuSections
                
                Spacer(minLength: 40)
            }
        }
        .background(Color.white)
        .task {
            await viewModel.loadUserStats()
        }
        .refreshable {
            await viewModel.loadUserStats()
        }
        .alert("로그아웃", isPresented: $showSignOutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                appState.signOut()
            }
        } message: {
            Text("정말 로그아웃하시겠습니까?")
        }
        .alert("회원탈퇴", isPresented: $showDeleteAccountAlert) {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }
        } message: {
            Text("정말 회원탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.")
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                // 프로필 아바타
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.1),
                                    Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                }
                
                // 사용자 정보
                VStack(spacing: 8) {
                    Text("사용자")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Clue 크리에이터")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .background(
            LinearGradient(
                colors: [Color.white, Color(red: 0.98, green: 0.99, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("나의 활동")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(spacing: 20) {
                statCard(
                    title: "캐릭터",
                    count: viewModel.isLoading ? "-" : "\(viewModel.characterCount)",
                    icon: "person.crop.circle",
                    color: Color(red: 0.0, green: 0.48, blue: 1.0)
                )
                
//                statCard(
//                    title: "시나리오",
//                    count: "0",
//                    icon: "book.pages",
//                    color: Color(red: 0.55, green: 0.27, blue: 0.95)
//                )
                
//                statCard(
//                    title: "스토리",
//                    count: "0",
//                    icon: "text.quote",
//                    color: Color(red: 1.0, green: 0.58, blue: 0.0)
//                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }
    
    // MARK: - Menu Sections
    private var menuSections: some View {
        VStack(spacing: 24) {
            // 앱 정보 섹션
            menuSection(
                title: "앱 정보",
                items: [
//                    ProfileMenuItem(
//                        icon: "questionmark.circle",
//                        title: "도움말",
//                        action: {
//                            // TODO: 도움말 페이지
//                        }
//                    ),
                    ProfileMenuItem(
                        icon: "doc.text",
                        title: "이용약관",
                        action: {
                            // TODO: 이용약관 페이지
                        }
                    ),
                    ProfileMenuItem(
                        icon: "hand.raised",
                        title: "개인정보처리방침",
                        action: {
                            // TODO: 개인정보처리방침 페이지
                        }
                    )
                ]
            )
            
            // 계정 관리 섹션
            menuSection(
                title: "계정 관리",
                items: [
                    ProfileMenuItem(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "로그아웃",
                        titleColor: Color(red: 1.0, green: 0.58, blue: 0.0),
                        action: {
                            showSignOutAlert = true
                        }
                    ),
                    ProfileMenuItem(
                        icon: "person.crop.circle.badge.minus",
                        title: "회원탈퇴",
                        titleColor: Color(red: 1.0, green: 0.23, blue: 0.19),
                        action: {
                            showDeleteAccountAlert = true
                        }
                    )
                ]
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color(red: 0.99, green: 0.99, blue: 1.0))
    }
    
    // MARK: - Helper Views
    private func statCard(title: String, count: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(count)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    private func menuSection(title: String? = nil, items: [ProfileMenuItem]) -> some View {
        VStack(spacing: 16) {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
            }
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    menuItem(item)
                    
                    if index < items.count - 1 {
                        Rectangle()
                            .fill(Color.black.opacity(0.06))
                            .frame(height: 1)
                            .padding(.leading, 52)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            )
        }
    }
    
    private func menuItem(_ item: ProfileMenuItem) -> some View {
        Button(action: item.action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill((item.titleColor ?? Color(red: 0.0, green: 0.48, blue: 1.0)).opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(item.titleColor ?? Color(red: 0.0, green: 0.48, blue: 1.0))
                }
                
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(item.titleColor ?? .black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Actions
    private func deleteAccount() async {
        do {
            try await viewModel.deleteAccount()
            appState.signOut()
        } catch {
            // 에러 처리 - 현재는 로그아웃만 처리
            appState.signOut()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
} 
