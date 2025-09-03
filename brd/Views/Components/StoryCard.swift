import SwiftUI

struct StoryCard: View {
    let item: ComboItem
    let cardNumber: Int
    let isVisible: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.medium) {
            // Card number indicator
            Text("\(cardNumber)")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textTertiary)
                .frame(width: 24)
            
            // Category icon
            Text(item.category.icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                Text(item.category.rawValue)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.categoryColor(for: item.category))
                
                Text(item.value)
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                .fill(AppTheme.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.categoryColor(for: item.category).opacity(0.3),
                                    AppTheme.Colors.categoryColor(for: item.category).opacity(0.1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: AppTheme.Shadows.softShadowColor,
            radius: AppTheme.Shadows.softShadowRadius,
            x: AppTheme.Shadows.softShadowX,
            y: AppTheme.Shadows.softShadowY
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .scaleEffect(isVisible ? 1 : 0.95)
    }
}

struct StoryCardCompact: View {
    let item: ComboItem
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Text(item.category.icon)
                .font(.system(size: 20))
            
            Text("\(item.category.rawValue):")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.categoryColor(for: item.category))
            
            Text(item.value)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.vertical, AppTheme.Spacing.xSmall)
        .padding(.horizontal, AppTheme.Spacing.small)
        .background(AppTheme.Colors.cardBackground.opacity(0.5))
        .cornerRadius(AppTheme.Layout.smallCornerRadius)
    }
}

#Preview {
    VStack {
        StoryCard(
            item: ComboItem(category: .character, value: "an introvert pirate"),
            cardNumber: 1,
            isVisible: true
        )
        
        StoryCard(
            item: ComboItem(category: .setting, value: "a rainy desert"),
            cardNumber: 2,
            isVisible: true
        )
        
        StoryCardCompact(
            item: ComboItem(category: .goal, value: "to unite rivals")
        )
    }
    .padding()
    .background(AppTheme.Colors.backgroundPrimary)
}