import SwiftUI

struct StoryView: View {
    @StateObject private var viewModel = StoryViewModel()
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        // Include Twist toggle
                        HStack {
                            HStack(spacing: AppTheme.Spacing.small) {
                                Image(systemName: viewModel.includeTwist ? "checkmark.square.fill" : "square")
                                    .foregroundColor(
                                        viewModel.includeTwist
                                        ? AppTheme.Colors.magicPurple
                                        : AppTheme.Colors.textTertiary
                                    )
                                    .font(.system(size: 20))
                                
                                Text("Include Twist")
                                    .font(AppTheme.Typography.bodyBold)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.toggleTwist()
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        .padding(.top, AppTheme.Spacing.small)
                        
                        // Story cards
                        VStack(spacing: AppTheme.Spacing.medium) {
                            if let combo = viewModel.storyCombo {
                                ForEach(Array(combo.items.enumerated()), id: \.element.category) { index, item in
                                    StoryCard(
                                        item: item,
                                        cardNumber: index + 1,
                                        isVisible: viewModel.cardsVisible[index]
                                    )
                                    .animation(
                                        .slideUp.delay(Double(index) * 0.1),
                                        value: viewModel.cardsVisible[index]
                                    )
                                }
                            } else {
                                // Empty state
                                VStack(spacing: AppTheme.Spacing.large) {
                                    Text("🐔")
                                        .font(.system(size: 80))
                                        .opacity(0.3)
                                    
                                    Text("Build your story!")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(AppTheme.Colors.headerText)
                                    
                                    Text("Tap Rebuild to create a sequential story with Character → Setting → Goal")
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, AppTheme.Spacing.xxLarge)
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        
                        // Action buttons
                        HStack(spacing: AppTheme.Spacing.medium) {
                            // Rebuild button
                            Button(action: {
                                viewModel.rebuild()
                            }) {
                                HStack(spacing: AppTheme.Spacing.xSmall) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Rebuild")
                                        .font(AppTheme.Typography.buttonLabel)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonModifier())
                            .disabled(viewModel.isGenerating)
                            .opacity(viewModel.isGenerating ? 0.6 : 1.0)
                            
                            // Save button
                            Button(action: {
                                viewModel.save()
                            }) {
                                Image(systemName: viewModel.isFavorite() ? "star.fill" : "star")
                                    .font(.system(size: 20))
                                    .frame(width: AppTheme.Layout.buttonHeight)
                            }
                            .buttonStyle(SecondaryButtonModifier())
                            .disabled(viewModel.storyCombo == nil)
                            .opacity(viewModel.storyCombo == nil ? 0.5 : 1.0)
                            
                            // Share button
                            if viewModel.storyCombo != nil {
                                ShareLink(item: viewModel.shareCombo()) {
                                    Image(systemName: AppTheme.Icons.share)
                                        .font(.system(size: 20))
                                        .frame(width: AppTheme.Layout.buttonHeight)
                                }
                                .buttonStyle(SecondaryButtonModifier())
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: AppTheme.Layout.buttonHeight, height: AppTheme.Layout.buttonHeight)
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        .padding(.bottom, AppTheme.Spacing.large)
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
                
                // Loading indicator
                if viewModel.isGenerating {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: AppTheme.Spacing.small) {
                            ProgressView()
                                .tint(AppTheme.Colors.emberOrange)
                            Text("Building story...")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .padding(.horizontal, AppTheme.Spacing.large)
                        .padding(.vertical, AppTheme.Spacing.medium)
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(AppTheme.Layout.cornerRadius)
                    }
                    .padding(.bottom, 150)
                }
            }
            .navigationTitle("Story Mode")
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
    StoryView(showSettings: .constant(false))
}