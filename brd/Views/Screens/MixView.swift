import SwiftUI

struct MixView: View {
    @StateObject private var viewModel = MixViewModel()
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        // Header text
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            HStack {
                                Text("Pick categories to shuffle:")
                                    .font(AppTheme.Typography.bodyBold)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                
                                Spacer()
                            }
                            
                            // Validation message
                            if let message = viewModel.validationMessage {
                                HStack(spacing: AppTheme.Spacing.xSmall) {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(AppTheme.Colors.fireRed)
                                        .font(.system(size: 14))
                                    
                                    Text(message)
                                        .font(AppTheme.Typography.footnote)
                                        .foregroundColor(AppTheme.Colors.fireRed)
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        .padding(.top, AppTheme.Spacing.small)
                        
                        // Category selection grid
                        CategoryGrid(
                            selectedCategories: viewModel.selectedCategories,
                            toggleAction: { category in
                                viewModel.toggleCategory(category)
                            }
                        )
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        
                        // Action buttons
                        HStack(spacing: AppTheme.Spacing.medium) {
                            // Roll Selected button
                            Button(action: {
                                viewModel.rollSelected()
                            }) {
                                HStack(spacing: AppTheme.Spacing.xSmall) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Roll Selected")
                                        .font(AppTheme.Typography.buttonLabel)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonModifier())
                            .disabled(!viewModel.canRoll || viewModel.isRolling)
                            .opacity(!viewModel.canRoll || viewModel.isRolling ? 0.6 : 1.0)
                            
                            // Save Last button
                            Button(action: {
                                viewModel.saveLast()
                            }) {
                                HStack(spacing: AppTheme.Spacing.xSmall) {
                                    Image(systemName: viewModel.isLastComboFavorite() ? "star.fill" : "star")
                                        .font(.system(size: 16))
                                    Text("Save Last")
                                        .font(AppTheme.Typography.buttonLabel)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryButtonModifier())
                            .disabled(!viewModel.canSaveLast)
                            .opacity(!viewModel.canSaveLast ? 0.5 : 1.0)
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        
                        // Result card
                        if let combo = viewModel.lastCombo {
                            VStack(spacing: AppTheme.Spacing.medium) {
                                MixResultCard(
                                    combo: combo,
                                    isVisible: !viewModel.isRolling
                                )
                                .animation(.cardReveal, value: viewModel.isRolling)
                                
                                // Share button
                                ShareLink(item: viewModel.shareCombo()) {
                                    HStack(spacing: AppTheme.Spacing.xSmall) {
                                        Image(systemName: AppTheme.Icons.share)
                                            .font(.system(size: 16))
                                        Text("Share")
                                            .font(AppTheme.Typography.buttonLabel)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(SecondaryButtonModifier())
                                .opacity(viewModel.isRolling ? 0.5 : 1.0)
                                .disabled(viewModel.isRolling)
                            }
                            .padding(.horizontal, AppTheme.Layout.screenPadding)
                        } else if !viewModel.selectedCategories.isEmpty {
                            // Empty state with selected categories preview
                            VStack(spacing: AppTheme.Spacing.medium) {
                                Text("🎲")
                                    .font(.system(size: 60))
                                    .opacity(0.3)
                                
                                Text("Ready to roll!")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                
                                Text("Selected: \(viewModel.getSelectedCategoriesText())")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, AppTheme.Spacing.large)
                        }
                        
                        Spacer(minLength: AppTheme.Spacing.xxLarge)
                    }
                }
                
                // Save confirmation toast
                if viewModel.showSaveConfirmation {
                    ToastView(
                        icon: "checkmark.circle.fill",
                        message: "Saved to Favorites.",
                        iconColor: AppTheme.Colors.gold
                    )
                    .padding(.bottom, 100)
                }
                
                // Rolling indicator
                if viewModel.isRolling {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: AppTheme.Spacing.small) {
                            ProgressView()
                                .tint(AppTheme.Colors.emberOrange)
                            Text("Rolling dice...")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .padding(.horizontal, AppTheme.Spacing.large)
                        .padding(.vertical, AppTheme.Spacing.medium)
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(AppTheme.Layout.cornerRadius)
                    }
                    .padding(.bottom, 200)
                }
            }
            .navigationTitle("Mix Mode")
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
}

#Preview {
    MixView(showSettings: .constant(false))
}