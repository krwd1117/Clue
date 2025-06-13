import SwiftUI

struct TossCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowOffset: CGSize
    
    init(
        padding: CGFloat = DesignSystem.Spacing.lg,
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 6,
        shadowOffset: CGSize = CGSize(width: 0, height: 3),
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(DesignSystem.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignSystem.Colors.borderLight, lineWidth: 1)
            )
            .cornerRadius(cornerRadius)
            .shadow(
                color: DesignSystem.Shadow.light,
                radius: shadowRadius,
                x: shadowOffset.width,
                y: shadowOffset.height
            )
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        TossCard {
            VStack {
                Text("기본 카드")
                    .font(.headline)
                Text("이것은 기본 Toss 스타일 카드입니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        
        TossCard(padding: DesignSystem.Spacing.md, cornerRadius: 12) {
            Text("작은 카드")
                .font(.caption)
        }
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
