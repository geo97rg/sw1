import SwiftUI

struct ComboCard: View {
    let combo: Combo?
    let isRolling: Bool
    @State private var rotationAngle: Double = 0
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            if let combo = combo {
                ForEach(combo.items, id: \.category) { item in
                    ComboItemRow(item: item)
                        .opacity(isRolling ? 0.6 : 1.0)
                        .blur(radius: isRolling ? 1 : 0)
                }
            } else {
                // Empty state
                VStack(spacing: AppTheme.Spacing.medium) {
                    Text("🐔")
                        .font(.system(size: 60))
                        .opacity(0.5)
                    
                    Text("Roll the dice to get started!")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.large)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .scaleEffect(isRolling ? 0.95 : 1.02)
        .rotationEffect(.degrees(rotationAngle))
        .offset(x: shakeOffset)
        .onChange(of: isRolling) { oldValue, newValue in
            if newValue {
                // Start rolling animation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    rotationAngle = Double.random(in: -4...4)
                }
                
                // Shake animation
                withAnimation(Animation.linear(duration: 0.1).repeatCount(5, autoreverses: true)) {
                    shakeOffset = 5
                }
                
                // Reset after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring()) {
                        rotationAngle = 0
                        shakeOffset = 0
                    }
                }
            }
        }
    }
}

struct ComboItemRow: View {
    let item: ComboItem
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
            // Category icon
            Text(item.category.icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                // Category label
                Text(item.category.rawValue)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.categoryColor(for: item.category))
                
                // Value
                Text(item.value)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    VStack {
        ComboCard(
            combo: Combo(items: [
                ComboItem(category: .character, value: "a torch-bearing chicken"),
                ComboItem(category: .setting, value: "an ember-lit dungeon"),
                ComboItem(category: .goal, value: "to relight the last torch"),
                ComboItem(category: .twist, value: "under flickering torchlight")
            ]),
            isRolling: false
        )
        
        ComboCard(combo: nil, isRolling: false)
    }
    .padding()
    .background(AppTheme.Colors.backgroundPrimary)
}