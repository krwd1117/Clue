import SwiftUI

struct TossButton: View {
    let title: String
    let icon: String?
    let style: TossButtonStyle
    let size: TossButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    enum TossButtonStyle {
        case primary
        case secondary
        case outline
        case ghost
        case destructive
    }
    
    enum TossButtonSize {
        case small
        case medium
        case large
        
        var height: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 48
            case .large: return 56
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 18
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 14
            case .large: return 16
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return DesignSystem.Spacing.md
            case .medium: return DesignSystem.Spacing.lg
            case .large: return DesignSystem.Spacing.xl
            }
        }
    }
    
    init(
        title: String,
        icon: String? = nil,
        style: TossButtonStyle = .primary,
        size: TossButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon, !isLoading {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .semibold))
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .semibold))
                }
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(backgroundView)
            .overlay(overlayView)
            .cornerRadius(16)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
        }
        .buttonStyle(TossButtonPressStyle())
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
    
    private var backgroundView: some View {
        Group {
            switch style {
            case .primary:
                LinearGradient(
                    gradient: Gradient(colors: [
                        DesignSystem.Colors.primary,
                        DesignSystem.Colors.primary.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .secondary:
                Color(DesignSystem.Colors.sectionBackground)
            case .outline, .ghost:
                Color.clear
            case .destructive:
                LinearGradient(
                    gradient: Gradient(colors: [
                        DesignSystem.Colors.accent,
                        DesignSystem.Colors.accent.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    private var overlayView: some View {
        Group {
            if style == .outline {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DesignSystem.Colors.borderLight, lineWidth: 1.5)
            } else {
                EmptyView()
            }
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return DesignSystem.Colors.textPrimary
        case .outline, .ghost:
            return DesignSystem.Colors.primary
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.primary.opacity(0.3)
        case .destructive:
            return DesignSystem.Colors.accent.opacity(0.3)
        default:
            return DesignSystem.Shadow.light
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary, .destructive:
            return 8
        case .secondary:
            return 4
        default:
            return 0
        }
    }
    
    private var shadowOffset: CGFloat {
        switch style {
        case .primary, .destructive:
            return 4
        case .secondary:
            return 2
        default:
            return 0
        }
    }
}

struct TossButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        TossButton(title: "Primary Button", icon: "sparkles") {}
        
        TossButton(title: "Secondary Button", style: .secondary) {}
        
        TossButton(title: "Outline Button", style: .outline) {}
        
        TossButton(title: "Ghost Button", style: .ghost) {}
        
        TossButton(title: "Destructive Button", style: .destructive) {}
        
        TossButton(title: "Loading...", isLoading: true) {}
        
        HStack(spacing: DesignSystem.Spacing.md) {
            TossButton(title: "Small", size: .small) {}
            TossButton(title: "Medium", size: .medium) {}
            TossButton(title: "Large", size: .large) {}
        }
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 
