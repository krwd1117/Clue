import SwiftUI

enum DesignSystem {
    // MARK: - Colors (Toss Style)
    enum Colors {
        // Primary colors
        static let primary = Color(red: 0.0, green: 0.4, blue: 1.0) // Toss blue
        static let secondary = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
        static let accent = Color(red: 1.0, green: 0.3, blue: 0.3) // Red accent
        
        // Background colors
        static let background = Color.white
        static let cardBackground = Color.white
        static let sectionBackground = Color(red: 0.98, green: 0.98, blue: 0.98)
        
        // Text colors
        static let textPrimary = Color.black
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.6)
        
        // Button colors
        static let buttonPrimary = Color(red: 0.0, green: 0.4, blue: 1.0)
        static let buttonSecondary = Color(red: 0.95, green: 0.95, blue: 0.95)
        static let buttonText = Color.white
        static let buttonTextSecondary = Color.black
        
        // Border colors
        static let border = Color(red: 0.9, green: 0.9, blue: 0.9)
        static let borderLight = Color(red: 0.95, green: 0.95, blue: 0.95)
    }
    
    // MARK: - Typography (Toss Style)
    enum Typography {
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .default)
        static let title = Font.system(size: 24, weight: .bold, design: .default)
        static let headline = Font.system(size: 18, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyBold = Font.system(size: 16, weight: .semibold, design: .default)
        static let caption = Font.system(size: 14, weight: .regular, design: .default)
        static let captionBold = Font.system(size: 14, weight: .semibold, design: .default)
        static let small = Font.system(size: 12, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing (Toss Style)
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
    }
    
    // MARK: - Corner Radius (Toss Style)
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Shadows (Toss Style)
    enum Shadow {
        static let light = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let heavy = Color.black.opacity(0.15)
    }
} 