import SwiftUI

struct DurationSelector: View {
    let durations: [Int]
    let selectedDuration: Int
    let onSelect: (Int) -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            ForEach(durations, id: \.self) { duration in
                DurationButton(
                    duration: duration,
                    isSelected: duration == selectedDuration,
                    action: { onSelect(duration) }
                )
            }
        }
    }
}

struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let action: () -> Void
    
    private var durationText: String {
        "\(duration)s"
    }
    
    var body: some View {
        Button(action: action) {
            Text(durationText)
                .font(AppTheme.Typography.bodyBold)
                .foregroundColor(
                    isSelected 
                    ? .white 
                    : AppTheme.Colors.textPrimary
                )
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.small)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                        .fill(
                            isSelected 
                            ? AppTheme.Colors.emberOrange
                            : AppTheme.Colors.cardBackground
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                                .stroke(
                                    isSelected 
                                    ? AppTheme.Colors.emberOrange
                                    : AppTheme.Colors.textTertiary.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct TimerDisplay: View {
    let timeString: String
    let isRunning: Bool
    let shouldPulse: Bool
    
    var body: some View {
        Text(timeString)
            .font(AppTheme.Typography.timerDisplay)
            .foregroundColor(timeRemaining > 10 ? AppTheme.Colors.textPrimary : AppTheme.Colors.fireRed)
            .scaleEffect(shouldPulse ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: shouldPulse)
    }
    
    private var timeRemaining: Int {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        return components.count == 2 ? components[0] * 60 + components[1] : 0
    }
}

struct ChallengeResultView: View {
    let message: String
    let combo: Combo?
    let onSave: () -> Void
    let onTryAnother: () -> Void
    let onBack: () -> Void
    let isFavorite: Bool
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            // Result message
            VStack(spacing: AppTheme.Spacing.medium) {
                Text(message.contains("finished") ? "🎉" : "💭")
                    .font(.system(size: 60))
                
                Text(message)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            
            // Action buttons
            VStack(spacing: AppTheme.Spacing.medium) {
                HStack(spacing: AppTheme.Spacing.medium) {
                    // Save button
                    Button(action: onSave) {
                        HStack(spacing: AppTheme.Spacing.xSmall) {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .font(.system(size: 16))
                            Text("Save")
                                .font(AppTheme.Typography.buttonLabel)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonModifier())
                    .disabled(combo == nil || isFavorite)
                    .opacity(combo == nil || isFavorite ? 0.6 : 1.0)
                    
                    // Try another button
                    Button(action: onTryAnother) {
                        HStack(spacing: AppTheme.Spacing.xSmall) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 16))
                            Text("Try another")
                                .font(AppTheme.Typography.buttonLabel)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonModifier())
                }
                
                // Back button
                Button(action: onBack) {
                    Text("Back")
                        .font(AppTheme.Typography.buttonLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonModifier())
            }
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.large) {
        DurationSelector(
            durations: [15, 30, 60, 120],
            selectedDuration: 60,
            onSelect: { _ in }
        )
        
        TimerDisplay(
            timeString: "01:23",
            isRunning: true,
            shouldPulse: true
        )
        
        ChallengeResultView(
            message: "Challenge finished.",
            combo: Combo(items: [
                ComboItem(category: .character, value: "a shy robot")
            ]),
            onSave: {},
            onTryAnother: {},
            onBack: {},
            isFavorite: false
        )
    }
    .padding()
    .background(AppTheme.Colors.backgroundPrimary)
}