import SwiftUI
import UIKit

enum FontHelper {
    // MARK: - Font Names (Static Fonts)
    enum NotoSansKR {
        // Static font names (recommended for iOS)
        static let thin = "NotoSansKR-Thin"
        static let extraLight = "NotoSansKR-ExtraLight"
        static let light = "NotoSansKR-Light"
        static let regular = "NotoSansKR-Regular"
        static let medium = "NotoSansKR-Medium"
        static let semiBold = "NotoSansKR-SemiBold"
        static let bold = "NotoSansKR-Bold"
        static let extraBold = "NotoSansKR-ExtraBold"
        static let black = "NotoSansKR-Black"
        
        // Alternative naming patterns (with spaces)
        static let thinAlt = "Noto Sans KR Thin"
        static let extraLightAlt = "Noto Sans KR ExtraLight"
        static let lightAlt = "Noto Sans KR Light"
        static let regularAlt = "Noto Sans KR Regular"
        static let mediumAlt = "Noto Sans KR Medium"
        static let semiBoldAlt = "Noto Sans KR SemiBold"
        static let boldAlt = "Noto Sans KR Bold"
        static let extraBoldAlt = "Noto Sans KR ExtraBold"
        static let blackAlt = "Noto Sans KR Black"
    }
    
    // MARK: - Font Loading Check
    static func isFontAvailable(_ fontName: String) -> Bool {
        return UIFont(name: fontName, size: 12) != nil
    }
    
    // MARK: - Safe Font Loading
    static func safeFont(name: String, size: CGFloat, fallback: Font) -> Font {
        if isFontAvailable(name) {
            return Font.custom(name, size: size)
        } else {
            print("⚠️ Font '\(name)' not found, using fallback")
            return fallback
        }
    }
    
    // MARK: - Try Multiple Font Names
    static func safeFontWithAlternatives(names: [String], size: CGFloat, fallback: Font) -> Font {
        for name in names {
            if isFontAvailable(name) {
                print("✅ Using font: \(name)")
                return Font.custom(name, size: size)
            }
        }
        print("⚠️ None of the fonts \(names) found, using fallback")
        return fallback
    }
    
    // MARK: - Debug Font List
    static func printAvailableFonts() {
        print("📝 Available Fonts:")
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family)")
            for name in names {
                print("  - \(name)")
            }
        }
    }
    
    // MARK: - Find NotoSansKR Fonts
    static func findNotoSansKRFonts() {
        print("🔍 Searching for NotoSansKR fonts...")
        let allFonts = UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }
        let notoFonts = allFonts.filter { $0.lowercased().contains("noto") }
        
        if notoFonts.isEmpty {
            print("❌ No NotoSansKR fonts found")
        } else {
            print("✅ Found NotoSansKR fonts:")
            for font in notoFonts {
                print("  - \(font)")
            }
        }
    }
    
    // MARK: - NotoSansKR Static Font Helpers
    static func notoSansKR(weight: Font.Weight, size: CGFloat) -> Font {
        let fallback = Font.system(size: size, weight: weight, design: .default)
        
        // Static Font 이름 매핑
        let fontName: String
        switch weight {
        case .black:
            fontName = NotoSansKR.black
        case .heavy:
            fontName = NotoSansKR.extraBold
        case .bold:
            fontName = NotoSansKR.bold
        case .semibold:
            fontName = NotoSansKR.semiBold
        case .medium:
            fontName = NotoSansKR.medium
        case .light:
            fontName = NotoSansKR.light
        case .ultraLight:
            fontName = NotoSansKR.extraLight
        case .thin:
            fontName = NotoSansKR.thin
        default:
            fontName = NotoSansKR.regular
        }
        
        // Static Font 시도
        if isFontAvailable(fontName) {
            print("✅ Using Static Font: \(fontName)")
            return Font.custom(fontName, size: size)
        }
        
        // 대체 이름 시도 (공백 포함 버전)
        let alternateFontName = fontName.replacingOccurrences(of: "NotoSansKR-", with: "Noto Sans KR ")
        if isFontAvailable(alternateFontName) {
            print("✅ Using Static Font (alternate): \(alternateFontName)")
            return Font.custom(alternateFontName, size: size)
        }
        
        print("⚠️ NotoSansKR '\(fontName)' not found, using system fallback")
        return fallback
    }
}

// MARK: - Font Extension for easier usage
extension Font {
    static func notoSansKR(_ weight: Font.Weight = .regular, size: CGFloat) -> Font {
        return FontHelper.notoSansKR(weight: weight, size: size)
    }
} 