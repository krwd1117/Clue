import SwiftUI

struct TossProgressBar: View {
    let progress: Double
    let height: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let animated: Bool
    
    init(
        progress: Double,
        height: CGFloat = 8,
        cornerRadius: CGFloat = 8,
        backgroundColor: Color = DesignSystem.Colors.sectionBackground,
        foregroundColor: Color = DesignSystem.Colors.primary,
        animated: Bool = true
    ) {
        self.progress = max(0, min(1, progress))
        self.height = height
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.animated = animated
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                foregroundColor,
                                foregroundColor.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(cornerRadius, geometry.size.width * progress),
                        height: height
                    )
                    .animation(
                        animated ? .easeInOut(duration: 0.3) : .none,
                        value: progress
                    )
            }
        }
        .frame(height: height)
    }
}

struct TossProgressCard: View {
    let title: String
    let subtitle: String
    let progress: Double
    let progressText: String
    
    init(
        title: String,
        subtitle: String,
        progress: Double,
        progressText: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.progressText = progressText ?? "\(Int(progress * 100))%"
    }
    
    var body: some View {
        TossCard {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        Text(subtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text(progressText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                TossProgressBar(progress: progress)
            }
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        TossProgressBar(progress: 0.7)
        
        TossProgressCard(
            title: "진행률",
            subtitle: "3/5 완료",
            progress: 0.6
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 