import SwiftUI

struct TossOptionButton: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let isSelected: Bool
    let style: TossOptionStyle
    let action: () -> Void
    
    enum TossOptionStyle {
        case radio
        case checkbox
        case card
        case minimal
        case compact
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        isSelected: Bool,
        style: TossOptionStyle = .card,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(TossOptionButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .radio, .checkbox:
            simpleContent
        case .card:
            cardContent
        case .minimal:
            minimalContent
        case .compact:
            compactContent
        }
    }
    
    private var simpleContent: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            selectionIndicator
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.borderLight,
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .cornerRadius(12)
    }
    
    private var cardContent: some View {
        VStack(spacing: 0) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                    .padding(.bottom, DesignSystem.Spacing.sm)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? DesignSystem.Colors.primary.opacity(0.08) : DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.border.opacity(0.3),
                            lineWidth: isSelected ? 1.5 : 0.5
                        )
                )
        )
    }
    
    private var minimalContent: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60) // 고정 높이
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.sectionBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.border.opacity(0.3),
                    lineWidth: isSelected ? 0 : 0.5
                )
        )
    }
    
    private var compactContent: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: subtitle != nil ? 60 : 50) // description이 있으면 높이 증가
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? DesignSystem.Colors.primary.opacity(0.1) : DesignSystem.Colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.border.opacity(0.2),
                    lineWidth: isSelected ? 1 : 0.5
                )
        )
    }
    
    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.sectionBackground)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(
                            isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
                            lineWidth: isSelected ? 0 : 1.5
                        )
                )
            
            if isSelected {
                Image(systemName: style == .checkbox ? "checkmark" : "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct TossOptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TossOptionGroup<T: Hashable>: View {
    let title: String?
    let options: [T]
    let selectedOption: T?
    let optionTitle: (T) -> String
    let optionSubtitle: ((T) -> String)?
    let style: TossOptionButton.TossOptionStyle
    let onSelection: (T) -> Void
    
    init(
        title: String? = nil,
        options: [T],
        selectedOption: T?,
        style: TossOptionButton.TossOptionStyle = .card,
        optionTitle: @escaping (T) -> String,
        optionSubtitle: ((T) -> String)? = nil,
        onSelection: @escaping (T) -> Void
    ) {
        self.title = title
        self.options = options
        self.selectedOption = selectedOption
        self.style = style
        self.optionTitle = optionTitle
        self.optionSubtitle = optionSubtitle
        self.onSelection = onSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            if let title = title {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.md) {
                ForEach(options, id: \.self) { option in
                    TossOptionButton(
                        title: optionTitle(option),
                        subtitle: optionSubtitle?(option),
                        isSelected: selectedOption == option,
                        style: style
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            onSelection(option)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.xl) {
        TossOptionButton(
            title: "카드 스타일",
            subtitle: "설명이 있는 옵션",
            isSelected: true,
            style: .card
        ) {}
        
        TossOptionButton(
            title: "라디오 스타일",
            isSelected: false,
            style: .radio
        ) {}
        
        TossOptionButton(
            title: "미니멀",
            icon: "star",
            isSelected: true,
            style: .minimal
        ) {}
        
        TossOptionGroup(
            title: "옵션 그룹",
            options: ["옵션 1", "옵션 2", "옵션 3"],
            selectedOption: "옵션 1",
            optionTitle: { $0 },
            optionSubtitle: { "설명: \($0)" }
        ) { _ in }
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 