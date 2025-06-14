import SwiftUI
import Supabase

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var contentOpacity: Double = 0
    @State private var logoScale: Double = 0.8
    
    let appState: AppState
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo and Title Section
                VStack(spacing: DesignSystem.Spacing.xxl) {
                    // App Logo
                    logoSection
                    
                    // Welcome Text
                    welcomeSection
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                
                Spacer()
                
                // Login Buttons Section
                VStack(spacing: DesignSystem.Spacing.lg) {
                    loginButtonsSection
                    
                    // Terms section
                    termsSection
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xxxl)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                contentOpacity = 1.0
                logoScale = 1.0
            }
        }
        .errorAlert(error: $viewModel.error)
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // App Icon
            ZStack {
                // Background Circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary,
                                DesignSystem.Colors.primary.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.3),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                
                // Icon
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleEffect(logoScale)
            
            // App Name
            Text("Clue")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("환영합니다")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("나만의 캐릭터와 스토리를\n만들어보세요")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }
    
    // MARK: - Login Buttons Section
    private var loginButtonsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Apple Login Button
            TossButton(
                title: "Apple로 계속하기",
                icon: "apple.logo",
                style: .primary,
                size: .large,
                isLoading: viewModel.isAppleLoading
            ) {
                Task {
                    await viewModel.signInWithOAuth(provier: .apple)
                    if viewModel.error == nil {
                        appState.signInCompleted()
                    }
                }
            }
            
            // Google Login Button
            TossButton(
                title: "Google로 계속하기",
                icon: "globe",
                style: .secondary,
                size: .large,
                isLoading: viewModel.isGoogleLoading
            ) {
                Task {
                    await viewModel.signInWithOAuth(provier: .google)
                    if viewModel.error == nil {
                        appState.signInCompleted()
                    }
                }
            }
        }
    }
    
    // MARK: - Terms Section
    private var termsSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("계속 진행하면 다음에 동의하는 것으로 간주됩니다")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 4) {
                Button("이용약관") {
                    // TODO: Show terms
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
                
                Text("및")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Button("개인정보처리방침") {
                    // TODO: Show privacy policy
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
}

#Preview {
    LoginView(appState: AppState())
} 
