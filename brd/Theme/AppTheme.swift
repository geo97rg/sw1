import SwiftUI

struct AppTheme {
    
    // MARK: - Colors
    struct Colors {
        // Background - улучшенная палитра
        static let backgroundPrimary = Color(red: 0.06, green: 0.06, blue: 0.08) // Deep graphite with slight blue
        static let backgroundSecondary = Color(red: 0.09, green: 0.09, blue: 0.12) // Lighter graphite
        static let cardBackground = Color(red: 0.13, green: 0.13, blue: 0.16) // Elevated dark panel
        static let surfaceElevated = Color(red: 0.16, green: 0.16, blue: 0.19) // Higher elevation
        
        // Accent Colors - более яркие для контраста
        static let emberOrange = Color(red: 1.0, green: 0.55, blue: 0.25) // Brighter ember
        static let fireRed = Color(red: 1.0, green: 0.3, blue: 0.25) // Brighter fire red
        static let gold = Color(red: 1.0, green: 0.87, blue: 0.15) // Warmer gold
        static let magicPurple = Color(red: 0.65, green: 0.45, blue: 0.9) // Brighter purple
        
        // Text - улучшенный контраст
        static let textPrimary = Color(red: 0.98, green: 0.98, blue: 1.0) // Slightly warm white
        static let textSecondary = Color(red: 0.85, green: 0.85, blue: 0.88) // Better contrast secondary
        static let textTertiary = Color(red: 0.65, green: 0.65, blue: 0.7) // More readable tertiary
        
        // Navigation and Headers - новые цвета
        static let navigationBackground = Color(red: 0.08, green: 0.08, blue: 0.11)
        static let headerText = Color(red: 1.0, green: 0.9, blue: 0.7) // Warm header text
        static let divider = Color(red: 0.25, green: 0.25, blue: 0.3) // Visible divider
        
        // Category Colors
        static func categoryColor(for category: Category) -> Color {
            switch category {
            case .character:
                return gold
            case .setting:
                return emberOrange
            case .goal:
                return fireRed
            case .twist:
                return magicPurple
            }
        }
    }
    
    // MARK: - Typography
    struct Typography {
        // Headers
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
        
        // Body
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
        static let caption = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        
        // Special
        static let buttonLabel = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let categoryLabel = Font.system(size: 16, weight: .medium, design: .rounded)
        static let timerDisplay = Font.system(size: 48, weight: .bold, design: .monospaced)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
    }
    
    // MARK: - Layout
    struct Layout {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 8
        static let buttonHeight: CGFloat = 48
        static let minTouchTarget: CGFloat = 44
        static let cardPadding: CGFloat = 20
        static let screenPadding: CGFloat = 16
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let cardShadowColor = Color.black.opacity(0.3)
        static let cardShadowRadius: CGFloat = 8
        static let cardShadowX: CGFloat = 0
        static let cardShadowY: CGFloat = 4
        
        static let softShadowColor = Color.black.opacity(0.2)
        static let softShadowRadius: CGFloat = 4
        static let softShadowX: CGFloat = 0
        static let softShadowY: CGFloat = 2
    }
    
    // MARK: - Icons
    struct Icons {
        static let shuffle = "dice"
        static let story = "book.fill"
        static let mix = "slider.horizontal.3"
        static let challenge = "timer"
        static let favorites = "star.fill"
        static let settings = "gearshape.fill"
        static let roll = "arrow.triangle.2.circlepath"
        static let save = "star"
        static let share = "square.and.arrow.up"
        static let chicken = "🐔"
        
        // Category Icons
        static func categoryIcon(for category: Category) -> String {
            switch category {
            case .character:
                return "🐔"
            case .setting:
                return "🏰"
            case .goal:
                return "🎯"
            case .twist:
                return "⚡"
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .padding(AppTheme.Layout.cardPadding)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.emberOrange.opacity(0.1),
                                AppTheme.Colors.gold.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: AppTheme.Shadows.cardShadowColor,
                radius: AppTheme.Shadows.cardShadowRadius,
                x: AppTheme.Shadows.cardShadowX,
                y: AppTheme.Shadows.cardShadowY
            )
    }
    
    func elevatedCardStyle() -> some View {
        self
            .padding(AppTheme.Layout.cardPadding)
            .background(AppTheme.Colors.surfaceElevated)
            .cornerRadius(AppTheme.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(AppTheme.Colors.emberOrange.opacity(0.2), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
    }
    
    func navigationHeaderStyle() -> some View {
        self
            .font(AppTheme.Typography.largeTitle)
            .foregroundColor(AppTheme.Colors.headerText)
            .padding(.horizontal, AppTheme.Layout.screenPadding)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.buttonLabel)
            .foregroundColor(.white)
            .frame(height: AppTheme.Layout.buttonHeight)
            .padding(.horizontal, AppTheme.Spacing.large)
            .background(AppTheme.Colors.emberOrange)
            .cornerRadius(AppTheme.Layout.smallCornerRadius)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.buttonLabel)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .frame(height: AppTheme.Layout.buttonHeight)
            .padding(.horizontal, AppTheme.Spacing.large)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.Layout.smallCornerRadius)
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonModifier: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .primaryButtonStyle()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonModifier: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .secondaryButtonStyle()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Animations
extension Animation {
    static let rollAnimation = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let cardReveal = Animation.easeOut(duration: 0.4)
    static let slideUp = Animation.easeOut(duration: 0.3)
}