import SwiftUI

struct TossActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let backgroundColor: Color
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        backgroundColor: Color = DesignSystem.Colors.primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Text content
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(backgroundColor)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(TossButtonPressStyle())
    }
}

struct TossRecentItemCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: (() -> Void)?
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(DesignSystem.Colors.sectionBackground)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                // Content
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Arrow
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
        }
        .disabled(action == nil)
        .buttonStyle(TossButtonPressStyle())
    }
}

struct TossAddNewCard: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    init(
        title: String,
        icon: String = "plus",
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background card with dashed border
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
                    .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
                
                // Dashed border overlay
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        Color(red: 0.0, green: 0.4, blue: 1.0).opacity(0.3),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [8, 6])
                    )
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.4, blue: 1.0).opacity(0.02),
                                Color.clear,
                                Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.01)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Content
                VStack(spacing: 16) {
                    // Plus icon with enhanced styling
                    ZStack {
                        // Outer glow
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.0, green: 0.4, blue: 1.0).opacity(0.08),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        // Main icon background
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.0, green: 0.4, blue: 1.0).opacity(0.1),
                                        Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 68, height: 68)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        Color(red: 0.0, green: 0.4, blue: 1.0).opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                        
                        // Plus icon
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Color(red: 0.0, green: 0.4, blue: 1.0))
                    }
                    
                    // Title
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.0, green: 0.4, blue: 1.0))
                    
                    // Subtitle
                    Text("새로운 캐릭터를 만들어보세요")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 28)
            }
            .frame(height: 180)
        }
        .buttonStyle(EnhancedTossCardButtonStyle())
    }
}

struct TossContentCard: View {
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    let action: (() -> Void)?
    
    init(
        title: String,
        description: String,
        icon: String,
        iconColor: Color = DesignSystem.Colors.primary,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                // Icon section
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(iconColor.opacity(0.1))
                        .frame(height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                // Content section
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .lineLimit(1)
                    
                    Text(description)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
        }
        .disabled(action == nil)
        .buttonStyle(TossButtonPressStyle())
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        HStack(spacing: DesignSystem.Spacing.md) {
            TossActionCard(
                title: "캐릭터 생성",
                subtitle: "새로운 캐릭터를\n만들어보세요",
                icon: "person.crop.circle.badge.plus",
                backgroundColor: DesignSystem.Colors.primary
            ) {}
            
            TossActionCard(
                title: "시나리오 생성",
                subtitle: "흥미진진한 이야기를\n시작해보세요",
                icon: "book.pages",
                backgroundColor: DesignSystem.Colors.accent
            ) {}
        }
        
        TossRecentItemCard(
            title: "마법사 엘리아",
            subtitle: "캐릭터 • 2시간 전",
            icon: "sparkles"
        ) {}
        
        HStack(spacing: DesignSystem.Spacing.md) {
            TossAddNewCard(title: "새 캐릭터") {}
            
            TossContentCard(
                title: "드래곤의 둥지",
                description: "고대 드래곤이 잠들어 있는 신비로운 동굴",
                icon: "flame",
                iconColor: DesignSystem.Colors.accent
            )
        }
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 
