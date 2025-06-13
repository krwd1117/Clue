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
            VStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.sectionBackground)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.border, style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5, 5]))
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
        }
        .buttonStyle(TossButtonPressStyle())
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
