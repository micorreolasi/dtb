// Theme.swift
// VisualDTB Design System

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        static let primaryDark = Color(hex: "1B2A4A")
        static let primaryMedium = Color(hex: "2C3E6B")
        static let primaryLight = Color(hex: "3D5A99")
        static let accent = Color(hex: "4A90D9")
        static let accentLight = Color(hex: "6BB5FF")
        
        static let background = Color(hex: "0F1923")
        static let surface = Color(hex: "1A2332")
        static let surfaceLight = Color(hex: "243447")
        
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "8899AA")
        static let textMuted = Color(hex: "556677")
        
        static let success = Color(hex: "27AE60")
        static let warning = Color(hex: "F39C12")
        static let danger = Color(hex: "E74C3C")
        
        static let sidebarBackground = Color(hex: "141E2B")
        static let sidebarSelected = Color(hex: "1E3A5F")
        
        // Projection colors
        static let projectionBg = Color.black
        static let projectionText = Color.white
    }
    
    // MARK: - Fonts
    struct Fonts {
        static func title(_ size: CGFloat = 28) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        static func heading(_ size: CGFloat = 20) -> Font {
            .system(size: size, weight: .semibold)
        }
        static func body(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .regular)
        }
        static func caption(_ size: CGFloat = 13) -> Font {
            .system(size: size, weight: .medium)
        }
        static func projection(_ size: CGFloat = 48) -> Font {
            .system(size: size, weight: .bold, design: .serif)
        }
    }
    
    // MARK: - Layout
    struct Layout {
        static let sidebarWidth: CGFloat = 70
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 12
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.Layout.cornerRadius)
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
    }
}

struct SidebarButtonStyle: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .frame(width: 56, height: 56)
            .background(isSelected ? AppTheme.Colors.sidebarSelected : .clear)
            .cornerRadius(12)
            .foregroundColor(isSelected ? AppTheme.Colors.accentLight : AppTheme.Colors.textSecondary)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func sidebarButton(isSelected: Bool) -> some View {
        modifier(SidebarButtonStyle(isSelected: isSelected))
    }
}
