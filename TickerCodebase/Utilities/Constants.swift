import SwiftUI

struct AppColors {
    // Core colors
    static let background = Color(hex: "000000")        // Pure black
    static let text = Color(hex: "FFFFFF")              // Pure white
    static let textSecondary = Color(hex: "999999")     // Light gray
    
    // Card backgrounds (very subtle gray, almost black)
    static let cardBackground = Color(hex: "0A0A0A")
    static let darkGray = Color(hex: "1a1a1a")
    
    // Borders (subtle)
    static let border = Color(hex: "333333")
    
    // Status colors ONLY (for good/bad indicators)
    static let green = Color(hex: "4ADE80")
    static let greenDark = Color(hex: "0a2817")
    static let greenBorder = Color(hex: "1a4d2e")
    static let red = Color(hex: "EF4444")
    static let redDark = Color(hex: "2a1515")
    static let redBorder = Color(hex: "4d1a1a")
    
    // NO GOLD. NO YELLOW. ONLY WHITE AND GRAY.
}

struct AppFonts {
    static let serifTitle = "Cormorant Garamond"
    static let body = "SF Pro Text"
}

struct AppConstants {
    static let openAIKey = "YOUR_OPENAI_API_KEY" // Replace with actual key
    static let cardCornerRadius: CGFloat = 12
    static let animationDuration: Double = 0.3
    
    // Spacing constants (matching React mockup)
    static let spacingXS: CGFloat = 8
    static let spacingSM: CGFloat = 12
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    
    // Typography sizes (matching React mockup)
    static let fontSizeHeader: CGFloat = 34
    static let fontSizeSubtitle: CGFloat = 10
    static let fontSizeTab: CGFloat = 13
    static let fontSizeCardTitle: CGFloat = 48
    static let fontSizeCardSubtitle: CGFloat = 16
    static let fontSizePrice: CGFloat = 24
    static let fontSizePriceChange: CGFloat = 14
    static let fontSizeTagline: CGFloat = 17
    static let fontSizeSectionHeader: CGFloat = 11
    static let fontSizeBody: CGFloat = 15
    static let fontSizeButton: CGFloat = 15
    
    // Letter spacing (tracking)
    static let trackingHeader: CGFloat = -0.5
    static let trackingSubtitle: CGFloat = 1.2
    static let trackingTab: CGFloat = 0.8
    static let trackingCardTitle: CGFloat = -1
    static let trackingSectionHeader: CGFloat = 1.0
    static let trackingButton: CGFloat = 0.5
}

struct PerformanceConfig {
    static let maxCachedCards = 20
    static let imageCompressionQuality: CGFloat = 0.8
    static let apiTimeout: TimeInterval = 30
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

