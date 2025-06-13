import SwiftUI

extension View {
    func gradientBackground() -> some View {
        self.background(
            DesignSystem.Colors.background
                .ignoresSafeArea()
        )
    }
    
    func errorAlert(error: Binding<AppError?>) -> some View {
        self.alert("오류", isPresented: .constant(error.wrappedValue != nil)) {
            Button("확인", role: .cancel) {
                error.wrappedValue = nil
            }
        } message: {
            if let error = error.wrappedValue {
                Text(error.localizedDescription)
            }
        }
    }
    
    func tossCardStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .shadow(color: DesignSystem.Shadow.light, radius: 8, x: 0, y: 2)
    }
    
    func tossSectionBackground() -> some View {
        self
            .background(DesignSystem.Colors.sectionBackground)
            .cornerRadius(DesignSystem.CornerRadius.md)
    }
    
    func cardStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.2),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    func glowEffect(color: Color = .white, radius: CGFloat = 10) -> some View {
        self.shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
    }
} 