import SwiftUI

struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var loadingOpacity: Double = 0
    
    let appState: AppState
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xxxl) {
                Spacer()
                
                // Logo section
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // App icon
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .fill(DesignSystem.Colors.primary)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .opacity(logoOpacity)
                    
                    // App name and description
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Clue")
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("캐릭터로 시작하는 나만의 이야기")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(textOpacity)
                }
                
                Spacer()
                
                // Loading section
                VStack(spacing: DesignSystem.Spacing.md) {
                    if appState.isCheckingSession {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                            .scaleEffect(1.2)
                        
                        Text("로그인 상태를 확인하고 있어요")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .opacity(loadingOpacity)
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.xl)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo fade in
        withAnimation(.easeOut(duration: 0.8)) {
            logoOpacity = 1.0
        }
        
        // Text fade in
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            textOpacity = 1.0
        }
        
        // Loading fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
            loadingOpacity = 1.0
        }
    }
}

#Preview {
    SplashView(appState: AppState())
} 
