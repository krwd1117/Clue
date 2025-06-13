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
        HStack(spacing: DesignSystem.Spacing.md) {
            selectionIndicator
            
            VStack(alignment: .leading, spacing: 4) {
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
            
            if isSelected {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.6))
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? DesignSystem.Colors.primary.opacity(0.05) : DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? DesignSystem.Colors.primary.opacity(0.3) : DesignSystem.Colors.borderLight,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .shadow(
            color: isSelected ? DesignSystem.Colors.primary.opacity(0.2) : DesignSystem.Shadow.light,
            radius: isSelected ? 8 : 4,
            x: 0,
            y: isSelected ? 4 : 2
        )
    }
    
    private var minimalContent: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary)
            
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.sectionBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
                    lineWidth: 1
                )
        )
        .cornerRadius(8)
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