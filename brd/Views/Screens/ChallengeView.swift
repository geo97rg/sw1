import SwiftUI

struct ChallengeView: View {
    @StateObject private var viewModel = ChallengeViewModel()
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Spacing.large) {
                    switch viewModel.challengeState {
                    case .setup:
                        setupView
                    case .running:
                        runningView
                    case .completed, .gaveUp:
                        resultView
                    }
                }
                .padding(AppTheme.Layout.screenPadding)
                
                // Save confirmation toast
                if viewModel.showSaveConfirmation {
                    ToastView(
                        icon: "checkmark.circle.fill",
                        message: "Saved to Favorites.",
                        iconColor: AppTheme.Colors.gold
                    )
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: AppTheme.Icons.settings)
                            .foregroundColor(AppTheme.Colors.headerText)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var setupView: some View {
        VStack(spacing: AppTheme.Spacing.xLarge) {
            // Duration picker
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                HStack {
                    Text("Pick duration")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                }
                
                DurationSelector(
                    durations: viewModel.availableDurations,
                    selectedDuration: viewModel.selectedDuration,
                    onSelect: { duration in
                        viewModel.selectDuration(duration)
                    }
                )
            }
            
            // Combo card
            if let combo = viewModel.currentCombo {
                ComboCard(combo: combo, isRolling: false)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: AppTheme.Spacing.medium) {
                // Start button
                Button(action: {
                    viewModel.startChallenge()
                }) {
                    HStack(spacing: AppTheme.Spacing.xSmall) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18))
                        Text("Start")
                            .font(AppTheme.Typography.buttonLabel)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonModifier())
                
                // New Combo button
                Button(action: {
                    viewModel.generateNewCombo()
                }) {
                    HStack(spacing: AppTheme.Spacing.xSmall) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 18))
                        Text("New Combo")
                            .font(AppTheme.Typography.buttonLabel)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonModifier())
            }
        }
    }
    
    @ViewBuilder
    private var runningView: some View {
        VStack(spacing: AppTheme.Spacing.xLarge) {
            Spacer()
            
            // Timer display
            VStack(spacing: AppTheme.Spacing.large) {
                Text("⏰")
                    .font(.system(size: 80))
                    .opacity(0.8)
                
                TimerDisplay(
                    timeString: viewModel.timeString,
                    isRunning: true,
                    shouldPulse: viewModel.timerPulse
                )
                
                Text("Time to get creative!")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Challenge combo (compact view)
            if let combo = viewModel.currentCombo {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                    ForEach(combo.items, id: \.category) { item in
                        HStack(spacing: AppTheme.Spacing.small) {
                            Text(item.category.icon)
                                .font(.system(size: 16))
                            
                            Text("\(item.category.rawValue):")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.categoryColor(for: item.category))
                            
                            Text(item.value)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Spacer()
                        }
                    }
                }
                .padding(AppTheme.Spacing.medium)
                .background(AppTheme.Colors.cardBackground.opacity(0.5))
                .cornerRadius(AppTheme.Layout.smallCornerRadius)
            }
            
            // Action buttons
            HStack(spacing: AppTheme.Spacing.medium) {
                // Done button
                Button(action: {
                    viewModel.completeChallenge()
                }) {
                    HStack(spacing: AppTheme.Spacing.xSmall) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18))
                        Text("Done")
                            .font(AppTheme.Typography.buttonLabel)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonModifier())
                
                // Give up button
                Button(action: {
                    viewModel.giveUp()
                }) {
                    HStack(spacing: AppTheme.Spacing.xSmall) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                        Text("Give up")
                            .font(AppTheme.Typography.buttonLabel)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonModifier())
            }
        }
    }
    
    @ViewBuilder
    private var resultView: some View {
        ChallengeResultView(
            message: viewModel.resultMessage,
            combo: viewModel.currentCombo,
            onSave: {
                viewModel.saveChallenge()
            },
            onTryAnother: {
                viewModel.tryAnother()
            },
            onBack: {
                viewModel.backToSetup()
            },
            isFavorite: viewModel.isFavorite()
        )
    }
}

#Preview {
    ChallengeView(showSettings: .constant(false))
}