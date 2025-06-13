import SwiftUI

struct FontTestView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text("NotoSansKR 폰트 테스트")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    FontSampleRow(
                        title: "Large Title",
                        font: DesignSystem.Typography.largeTitle,
                        text: "안녕하세요! 큰 제목입니다"
                    )
                    
                    FontSampleRow(
                        title: "Title",
                        font: DesignSystem.Typography.title,
                        text: "제목 텍스트입니다"
                    )
                    
                    FontSampleRow(
                        title: "Headline",
                        font: DesignSystem.Typography.headline,
                        text: "헤드라인 텍스트입니다"
                    )
                    
                    FontSampleRow(
                        title: "Body",
                        font: DesignSystem.Typography.body,
                        text: "본문 텍스트입니다. 일반적인 내용을 표시할 때 사용합니다."
                    )
                    
                    FontSampleRow(
                        title: "Body Bold",
                        font: DesignSystem.Typography.bodyBold,
                        text: "굵은 본문 텍스트입니다. 강조할 내용에 사용합니다."
                    )
                    
                    FontSampleRow(
                        title: "Caption",
                        font: DesignSystem.Typography.caption,
                        text: "캡션 텍스트입니다. 부가 설명에 사용합니다."
                    )
                    
                    FontSampleRow(
                        title: "Caption Bold",
                        font: DesignSystem.Typography.captionBold,
                        text: "굵은 캡션 텍스트입니다."
                    )
                    
                    FontSampleRow(
                        title: "Small",
                        font: DesignSystem.Typography.small,
                        text: "작은 텍스트입니다. 세부 정보에 사용합니다."
                    )
                }
                
                Divider()
                    .padding(.vertical, DesignSystem.Spacing.md)
                
                // Static Font Weight Test
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Static Font Weight 테스트")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        StaticFontWeightRow(weight: .thin, text: "Thin")
                        StaticFontWeightRow(weight: .ultraLight, text: "ExtraLight")
                        StaticFontWeightRow(weight: .light, text: "Light")
                        StaticFontWeightRow(weight: .regular, text: "Regular")
                        StaticFontWeightRow(weight: .medium, text: "Medium")
                        StaticFontWeightRow(weight: .semibold, text: "SemiBold")
                        StaticFontWeightRow(weight: .bold, text: "Bold")
                        StaticFontWeightRow(weight: .heavy, text: "ExtraBold")
                        StaticFontWeightRow(weight: .black, text: "Black")
                    }
                }
                
                Divider()
                    .padding(.vertical, DesignSystem.Spacing.md)
                
                // Font availability check
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("폰트 가용성 체크")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    FontAvailabilityRow(fontName: "NotoSansKR-Thin")
                    FontAvailabilityRow(fontName: "NotoSansKR-ExtraLight")
                    FontAvailabilityRow(fontName: "NotoSansKR-Light")
                    FontAvailabilityRow(fontName: "NotoSansKR-Regular")
                    FontAvailabilityRow(fontName: "NotoSansKR-Medium")
                    FontAvailabilityRow(fontName: "NotoSansKR-SemiBold")
                    FontAvailabilityRow(fontName: "NotoSansKR-Bold")
                    FontAvailabilityRow(fontName: "NotoSansKR-ExtraBold")
                    FontAvailabilityRow(fontName: "NotoSansKR-Black")
                }
                
                Spacer(minLength: DesignSystem.Spacing.xl)
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("폰트 테스트")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Debug: Find NotoSansKR fonts specifically
            FontHelper.findNotoSansKRFonts()
        }
    }
}

struct FontSampleRow: View {
    let title: String
    let font: Font
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(title)
                .font(DesignSystem.Typography.small)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text(text)
                .font(font)
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
        .cornerRadius(DesignSystem.CornerRadius.sm)
    }
}

struct FontAvailabilityRow: View {
    let fontName: String
    
    var body: some View {
        HStack {
            Text(fontName)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Spacer()
            
            Image(systemName: FontHelper.isFontAvailable(fontName) ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(FontHelper.isFontAvailable(fontName) ? .green : .red)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

struct StaticFontWeightRow: View {
    let weight: Font.Weight
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .frame(width: 80, alignment: .leading)
            
            Text("가나다라마바사 ABC 123")
                .font(.notoSansKR(weight, size: 16))
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

#Preview {
    NavigationView {
        FontTestView()
    }
} 