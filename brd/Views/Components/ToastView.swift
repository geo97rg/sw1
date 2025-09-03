import SwiftUI

struct ToastView: View {
    let icon: String
    let message: String
    let iconColor: Color
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: AppTheme.Spacing.xSmall) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(message)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.vertical, AppTheme.Spacing.medium)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.Layout.cornerRadius)
            .shadow(
                color: AppTheme.Shadows.softShadowColor,
                radius: AppTheme.Shadows.softShadowRadius,
                x: AppTheme.Shadows.softShadowX,
                y: AppTheme.Shadows.softShadowY
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.backgroundPrimary
            .ignoresSafeArea()
        
        VStack(spacing: AppTheme.Spacing.large) {
            ToastView(
                icon: "dice",
                message: "New combo ready.",
                iconColor: AppTheme.Colors.emberOrange
            )
            
            ToastView(
                icon: "checkmark.circle.fill",
                message: "Saved to Favorites.",
                iconColor: AppTheme.Colors.gold
            )
            
            ToastView(
                icon: "trash.fill",
                message: "Removed.",
                iconColor: AppTheme.Colors.fireRed
            )
        }
    }
}