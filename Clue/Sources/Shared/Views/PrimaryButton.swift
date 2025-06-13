import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    let style: ButtonStyle
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
    }
    
    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(DesignSystem.Typography.bodyBold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(borderColor, lineWidth: style == .outline ? 1 : 0)
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.buttonPrimary
        case .secondary:
            return DesignSystem.Colors.buttonSecondary
        case .outline:
            return Color.clear
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.buttonText
        case .secondary, .outline:
            return DesignSystem.Colors.buttonTextSecondary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outline:
            return DesignSystem.Colors.border
        default:
            return Color.clear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Shadow.light
        default:
            return Color.clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary:
            return 4
        default:
            return 0
        }
    }
    
    private var shadowY: CGFloat {
        switch style {
        case .primary:
            return 2
        default:
            return 0
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.md) {
        PrimaryButton(title: "Apple로 계속하기", icon: "apple.logo") {}
        PrimaryButton(title: "Google로 계속하기", icon: "globe", style: .secondary) {}
        PrimaryButton(title: "계속하기", style: .outline) {}
        PrimaryButton(title: "로딩 중...", isLoading: true) {}
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 