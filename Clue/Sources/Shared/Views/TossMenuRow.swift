import SwiftUI

struct TossMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let titleColor: Color
    let showChevron: Bool
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        titleColor: Color = DesignSystem.Colors.textPrimary,
        showChevron: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.titleColor = titleColor
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(DesignSystem.Colors.sectionBackground)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(titleColor)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
                
                Spacer()
                
                // Chevron
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(TossMenuRowStyle())
    }
}

struct TossMenuRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed ? 
                DesignSystem.Colors.sectionBackground.opacity(0.5) : 
                Color.clear
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TossMenuSection: View {
    let title: String?
    let items: [TossMenuRowItem]
    
    struct TossMenuRowItem {
        let icon: String
        let title: String
        let subtitle: String?
        let titleColor: Color
        let showChevron: Bool
        let action: () -> Void
        
        init(
            icon: String,
            title: String,
            subtitle: String? = nil,
            titleColor: Color = DesignSystem.Colors.textPrimary,
            showChevron: Bool = true,
            action: @escaping () -> Void
        ) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.titleColor = titleColor
            self.showChevron = showChevron
            self.action = action
        }
    }
    
    init(
        title: String? = nil,
        items: [TossMenuRowItem]
    ) {
        self.title = title
        self.items = items
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = title {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.sm)
            }
            
            TossCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]
                        
                        TossMenuRow(
                            icon: item.icon,
                            title: item.title,
                            subtitle: item.subtitle,
                            titleColor: item.titleColor,
                            showChevron: item.showChevron,
                            action: item.action
                        )
                        
                        if index < items.count - 1 {
                            Divider()
                                .padding(.leading, DesignSystem.Spacing.lg + 32 + DesignSystem.Spacing.md)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        TossMenuRow(
            icon: "person.circle",
            title: "프로필 설정",
            subtitle: "개인정보 및 계정 관리"
        ) {}
        
        TossMenuSection(
            title: "설정",
            items: [
                .init(icon: "bell", title: "알림 설정") {},
                .init(icon: "lock", title: "개인정보 보호") {},
                .init(icon: "questionmark.circle", title: "도움말") {},
                .init(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "로그아웃",
                    titleColor: DesignSystem.Colors.accent,
                    showChevron: false
                ) {}
            ]
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 