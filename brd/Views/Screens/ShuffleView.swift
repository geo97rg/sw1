import SwiftUI

struct ShuffleView: View {
    @StateObject private var viewModel = ShuffleViewModel()
    @StateObject private var dailyManager = DailyManager.shared
    @Binding var showSettings: Bool
    @State private var showDailyDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Daily Banner
                    Button(action: {
                        if !dailyManager.isDailyRevealed {
                            dailyManager.revealDaily()
                        } else if dailyManager.dailyCombo != nil {
                            showDailyDetail = true
                        }
                    }) {
                        DailyBanner()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, AppTheme.Layout.screenPadding)
                    .padding(.top, AppTheme.Spacing.small)
                    
                    Spacer()
                    
                    // Main combo card
                    ComboCard(
                        combo: viewModel.currentCombo,
                        isRolling: viewModel.isRolling
                    )
                    .padding(.horizontal, AppTheme.Layout.screenPadding)
                    
                    // Action buttons
                    HStack(spacing: AppTheme.Spacing.medium) {
                        // Roll button
                        Button(action: {
                            viewModel.roll()
                        }) {
                            HStack(spacing: AppTheme.Spacing.xSmall) {
                                Image(systemName: AppTheme.Icons.roll)
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Roll")
                                    .font(AppTheme.Typography.buttonLabel)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonModifier())
                        
                        // Save button
                        Button(action: {
                            viewModel.save()
                        }) {
                            Image(systemName: viewModel.isFavorite() ? "star.fill" : AppTheme.Icons.save)
                                .font(.system(size: 20))
                                .frame(width: AppTheme.Layout.buttonHeight)
                        }
                        .buttonStyle(SecondaryButtonModifier())
                        .disabled(viewModel.currentCombo == nil)
                        .opacity(viewModel.currentCombo == nil ? 0.5 : 1.0)
                        
                        // Share button
                        if viewModel.currentCombo != nil {
                            ShareLink(item: viewModel.shareCombo()) {
                                Image(systemName: AppTheme.Icons.share)
                                    .font(.system(size: 20))
                                    .frame(width: AppTheme.Layout.buttonHeight)
                            }
                            .buttonStyle(SecondaryButtonModifier())
                        } else {
                            // Placeholder for consistent layout
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: AppTheme.Layout.buttonHeight, height: AppTheme.Layout.buttonHeight)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.screenPadding)
                    .padding(.top, AppTheme.Spacing.large)
                    
                    Spacer()
                }
                
                // Success toasts
                if viewModel.showSaveConfirmation {
                    ToastView(
                        icon: "checkmark.circle.fill",
                        message: "Saved to Favorites.",
                        iconColor: AppTheme.Colors.gold
                    )
                    .padding(.bottom, 100)
                }
                
                if viewModel.showRemoveConfirmation {
                    ToastView(
                        icon: "trash.fill",
                        message: "Removed.",
                        iconColor: AppTheme.Colors.fireRed
                    )
                    .padding(.bottom, 100)
                }
                
                if viewModel.showRollSuccess {
                    ToastView(
                        icon: "dice",
                        message: "New combo ready.",
                        iconColor: AppTheme.Colors.emberOrange
                    )
                    .padding(.bottom, 160)
                }
            }
            .navigationTitle("Brainstorm Dice")
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
        .sheet(isPresented: $showDailyDetail) {
            if let dailyCombo = dailyManager.dailyCombo {
                DailyDetailView(combo: dailyCombo, showDailyDetail: $showDailyDetail)
            }
        }
    }
}

struct DailyDetailView: View {
    let combo: Combo
    @Binding var showDailyDetail: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showSaveConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Spacing.large) {
                    Text("🐔")
                        .font(.system(size: 60))
                        .padding(.top)
                    
                    Text("Daily Shuffle - \(DailyManager.shared.getDailyDateString())")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.gold)
                    
                    ComboCard(combo: combo, isRolling: false)
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                    
                    HStack(spacing: AppTheme.Spacing.medium) {
                        Button(action: {
                            if StorageManager.shared.isFavorite(combo) {
                                StorageManager.shared.removeFavorite(combo)
                            } else {
                                StorageManager.shared.saveFavorite(combo)
                            }
                            withAnimation {
                                showSaveConfirmation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSaveConfirmation = false
                                }
                            }
                        }) {
                            HStack(spacing: AppTheme.Spacing.xSmall) {
                                Image(systemName: StorageManager.shared.isFavorite(combo) ? "star.fill" : "star")
                                Text(StorageManager.shared.isFavorite(combo) ? "Remove" : "Save")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonModifier())
                        
                        ShareLink(item: combo.shareText) {
                            HStack(spacing: AppTheme.Spacing.xSmall) {
                                Image(systemName: AppTheme.Icons.share)
                                Text("Share")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryButtonModifier())
                    }
                    .padding(.horizontal, AppTheme.Layout.screenPadding)
                    
                    Spacer()
                }
                
                // Save confirmation
                if showSaveConfirmation {
                    ToastView(
                        icon: "checkmark.circle.fill",
                        message: "Saved to Favorites.",
                        iconColor: AppTheme.Colors.gold
                    )
                    .padding(.bottom, 50)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showDailyDetail = false
                    }
                    .foregroundColor(AppTheme.Colors.headerText)
                }
            }
        }
    }
}

#Preview {
    ShuffleView(showSettings: .constant(false))
}