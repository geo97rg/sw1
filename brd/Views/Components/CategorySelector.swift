import SwiftUI

struct CategorySelector: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                // Category icon
                Text(category.icon)
                    .font(.system(size: 22))
                
                // Category name
                Text(category.rawValue)
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                // Checkbox
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(
                        isSelected 
                        ? AppTheme.Colors.categoryColor(for: category)
                        : AppTheme.Colors.textTertiary
                    )
                    .font(.system(size: 22))
            }
            .padding(AppTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                    .fill(AppTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                            .stroke(
                                isSelected 
                                ? AppTheme.Colors.categoryColor(for: category).opacity(0.4)
                                : AppTheme.Colors.textTertiary.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct CategoryGrid: View {
    let categories = Category.allCases
    let selectedCategories: Set<Category>
    let toggleAction: (Category) -> Void
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.small),
                GridItem(.flexible(), spacing: AppTheme.Spacing.small)
            ],
            spacing: AppTheme.Spacing.small
        ) {
            ForEach(categories, id: \.self) { category in
                CategorySelector(
                    category: category,
                    isSelected: selectedCategories.contains(category),
                    action: { toggleAction(category) }
                )
            }
        }
    }
}

struct MixResultCard: View {
    let combo: Combo
    let isVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack {
                Text("Result")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                
                Spacer()
                
                // Category icons preview
                HStack(spacing: AppTheme.Spacing.xxSmall) {
                    ForEach(combo.items, id: \.category) { item in
                        Text(item.category.icon)
                            .font(.system(size: 16))
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                ForEach(combo.items, id: \.category) { item in
                    HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
                        Text(item.category.rawValue + ":")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.categoryColor(for: item.category))
                            .frame(width: 74, alignment: .leading)
                        
                        Text(item.value)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
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
                                    AppTheme.Colors.emberOrange.opacity(0.3),
                                    AppTheme.Colors.gold.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: AppTheme.Shadows.cardShadowColor,
            radius: AppTheme.Shadows.cardShadowRadius,
            x: AppTheme.Shadows.cardShadowX,
            y: AppTheme.Shadows.cardShadowY
        )
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.95)
        .offset(y: isVisible ? 0 : 20)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.large) {
        CategoryGrid(
            selectedCategories: [.character, .setting],
            toggleAction: { _ in }
        )
        
        MixResultCard(
            combo: Combo(items: [
                ComboItem(category: .character, value: "a shy robot"),
                ComboItem(category: .setting, value: "a rainy desert")
            ]),
            isVisible: true
        )
    }
    .padding()
    .background(AppTheme.Colors.backgroundPrimary)
}
