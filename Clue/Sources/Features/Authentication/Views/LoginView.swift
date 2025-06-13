import SwiftUI
import Supabase

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var contentOpacity: Double = 0
    
    let appState: AppState
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xxxl) {
                    // Header section
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // App icon
                        ZStack {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                .fill(DesignSystem.Colors.primary)
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Clue에 오신 것을 환영해요")
                                .font(DesignSystem.Typography.title)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("간편하게 로그인하고\n캐릭터 생성을 시작해보세요")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xxxl)
                    
                    // Login buttons section
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            PrimaryButton(
                                title: "Apple로 계속하기",
                                icon: "apple.logo",
                                style: .primary,
                                isLoading: viewModel.isAppleLoading
                            ) {
                                Task {
                                    await viewModel.signInWithApple()
                                    if viewModel.error == nil {
                                        appState.signInCompleted()
                                    }
                                }
                            }
                            
                            PrimaryButton(
                                title: "Google로 계속하기",
                                icon: "globe",
                                style: .secondary,
                                isLoading: viewModel.isGoogleLoading
                            ) {
                                Task {
                                    await viewModel.signInWithGoogle()
                                    if viewModel.error == nil {
                                        appState.signInCompleted()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    Spacer(minLength: DesignSystem.Spacing.xxxl)
                    
                    // Terms and privacy
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("계속 진행하면 다음에 동의하는 것으로 간주됩니다")
                            .font(DesignSystem.Typography.small)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Button("이용약관") {
                                // TODO: Show terms
                            }
                            .font(DesignSystem.Typography.small)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .underline()
                            
                            Text("·")
                                .font(DesignSystem.Typography.small)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            Button("개인정보처리방침") {
                                // TODO: Show privacy policy
                            }
                            .font(DesignSystem.Typography.small)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .underline()
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                contentOpacity = 1.0
            }
        }
        .errorAlert(error: $viewModel.error)
    }
}

#Preview {
    LoginView(appState: AppState())
} 
