import SwiftUI

struct TossLoadingView: View {
    let title: String
    let subtitle: String?
    let style: TossLoadingStyle
    
    enum TossLoadingStyle {
        case card
        case fullscreen
        case inline
    }
    
    init(
        title: String = "로딩 중...",
        subtitle: String? = nil,
        style: TossLoadingStyle = .card
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
    }
    
    var body: some View {
        switch style {
        case .card:
            cardContent
        case .fullscreen:
            fullscreenContent
        case .inline:
            inlineContent
        }
    }
    
    private var cardContent: some View {
        TossCard(padding: DesignSystem.Spacing.xl, cornerRadius: 20) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                loadingIndicator
                TextContent(title: title, subtitle: subtitle)
            }
        }
    }
    
    private var fullscreenContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            TossCard(padding: DesignSystem.Spacing.xl, cornerRadius: 20) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    loadingIndicator
                    TextContent(title: title, subtitle: subtitle)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
    
    private var inlineContent: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                .scaleEffect(0.8)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(DesignSystem.Spacing.md)
    }
    
    private var loadingIndicator: some View {
        LoadingSpinner()
    }
}

struct LoadingSpinner: View {
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 4)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            DesignSystem.Colors.primary,
                            DesignSystem.Colors.primary.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        isRotating = true
                    }
                }
        }
    }
}

fileprivate struct TextContent: View {
    var title: String
    var subtitle: String?
    
    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct TossSkeletonView: View {
    let lines: Int
    let showAvatar: Bool
    
    @State private var isAnimating = false
    
    init(lines: Int = 3, showAvatar: Bool = false) {
        self.lines = lines
        self.showAvatar = showAvatar
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            if showAvatar {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Circle()
                        .fill(skeletonGradient)
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(skeletonGradient)
                            .frame(height: 16)
                            .frame(maxWidth: 120)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(skeletonGradient)
                            .frame(height: 14)
                            .frame(maxWidth: 80)
                    }
                    
                    Spacer()
                }
            }
            
            ForEach(0..<lines, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(skeletonGradient)
                    .frame(height: 16)
                    .frame(maxWidth: index == lines - 1 ? .infinity * 0.7 : .infinity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var skeletonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                DesignSystem.Colors.sectionBackground,
                DesignSystem.Colors.sectionBackground.opacity(0.5),
                DesignSystem.Colors.sectionBackground
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct TossEmptyStateView: View {
    let title: String
    let subtitle: String?
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String = "tray",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.sectionBackground)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                }
            }
            
            if let actionTitle = actionTitle, let action = action {
                TossButton(
                    title: actionTitle,
                    style: .outline,
                    action: action
                )
                .frame(maxWidth: 200)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.xl) {
        TossLoadingView(
            title: "카테고리를 불러오는 중...",
            subtitle: "잠시만 기다려주세요",
            style: .card
        )
        
        TossLoadingView(
            title: "처리 중...",
            style: .inline
        )
        
        TossCard {
            TossSkeletonView(lines: 3, showAvatar: true)
        }
        
        TossEmptyStateView(
            title: "아직 캐릭터가 없어요",
            subtitle: "새로운 캐릭터를 만들어보세요",
            icon: "person.badge.plus",
            actionTitle: "캐릭터 만들기"
        ) {}
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 
