import SwiftUI

struct DailyBanner: View {
    @StateObject private var dailyManager = DailyManager.shared
    @State private var showGlow = false
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Text("🐔")
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                Text("Daily Shuffle")
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.gold)
                
                if dailyManager.isDailyRevealed, let combo = dailyManager.dailyCombo {
                    // Show mini preview of combo
                    Text(combo.items.map { $0.category.icon }.joined(separator: " "))
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Text("Tap to reveal")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            if !dailyManager.isDailyRevealed {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            } else if dailyManager.dailyCombo != nil {
                Image(systemName: "arrow.up.right.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.Colors.gold.opacity(0.7))
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                .fill(AppTheme.Colors.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                        .stroke(
                            showGlow ? AppTheme.Colors.gold.opacity(0.6) : AppTheme.Colors.gold.opacity(0.2),
                            lineWidth: showGlow ? 2 : 1
                        )
                )
                .shadow(
                    color: showGlow ? AppTheme.Colors.gold.opacity(0.3) : AppTheme.Colors.emberOrange.opacity(0.1),
                    radius: showGlow ? 12 : 6,
                    x: 0,
                    y: showGlow ? 4 : 2
                )
        )
        .scaleEffect(showGlow ? 1.02 : 1.0)
        .onChange(of: dailyManager.isDailyRevealed) { oldValue, newValue in
            if newValue && !oldValue {
                withAnimation(.cardReveal) {
                    showGlow = true
                }
                
                // Remove glow after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        showGlow = false
                    }
                }
            }
        }
    }
}

#Preview {
    DailyBanner()
        .padding()
        .background(AppTheme.Colors.backgroundPrimary)
}