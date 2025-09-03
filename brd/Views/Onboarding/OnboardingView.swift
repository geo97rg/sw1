import SwiftUI

struct OnboardingView: View {
    @StateObject private var storageManager = StorageManager.shared
    @State private var currentStep = 0
    @State private var selectedCategories = Set(Category.allCases)
    
    var body: some View {
        ZStack {
            // Dungeon ambience background
            LinearGradient(
                colors: [
                    AppTheme.Colors.backgroundPrimary,
                    AppTheme.Colors.backgroundSecondary.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Stone texture overlay (simulated)
            Rectangle()
                .fill(
                    ImagePaint(
                        image: Image(systemName: "circle.fill"),
                        scale: 0.01
                    )
                    .opacity(0.02)
                )
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicators
                HStack(spacing: AppTheme.Spacing.xSmall) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index <= currentStep ? AppTheme.Colors.emberOrange : AppTheme.Colors.cardBackground)
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, AppTheme.Layout.screenPadding)
                .padding(.top, 60)
                
                Spacer()
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1
                    OnboardingStep1()
                        .tag(0)
                    
                    // Step 2
                    OnboardingStep2(selectedCategories: $selectedCategories)
                        .tag(1)
                    
                    // Step 3
                    OnboardingStep3()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
                
                // Continue button
                Button(action: {
                    if currentStep < 2 {
                        withAnimation {
                            currentStep += 1
                        }
                    } else {
                        // Complete onboarding
                        for category in Category.allCases {
                            if !selectedCategories.contains(category) {
                                storageManager.toggleCategory(category)
                            }
                        }
                        storageManager.completeOnboarding()
                    }
                }) {
                    Text(currentStep < 2 ? "Continue" : "Start Brainstorming")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonModifier())
                .padding(.horizontal, AppTheme.Layout.screenPadding)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingStep1: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xLarge) {
            // Dungeon ambience illustration
            ZStack {
                // Torch glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.emberOrange.opacity(0.3),
                                AppTheme.Colors.emberOrange.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                
                // Chicken mascot
                Text("🐔")
                    .font(.system(size: 100))
                    .shadow(color: AppTheme.Colors.emberOrange.opacity(0.5), radius: 10)
            }
            
            Text("Roll the dice for creative combos.")
                .font(AppTheme.Typography.title)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppTheme.Layout.screenPadding)
    }
}

struct OnboardingStep2: View {
    @Binding var selectedCategories: Set<Category>
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xLarge) {
            Text("Pick categories you want to use.")
                .font(AppTheme.Typography.title)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: AppTheme.Spacing.small) {
                ForEach(Category.allCases, id: \.self) { category in
                    CategoryToggle(
                        category: category,
                        isSelected: selectedCategories.contains(category),
                        action: {
                            if selectedCategories.contains(category) {
                                if selectedCategories.count > 1 {
                                    selectedCategories.remove(category)
                                }
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    )
                }
            }
            
            Text("You can change this later in Settings.")
                .font(AppTheme.Typography.footnote)
                .foregroundColor(AppTheme.Colors.textTertiary)
                .padding(.top, AppTheme.Spacing.small)
        }
        .padding(.horizontal, AppTheme.Layout.screenPadding)
    }
}

struct OnboardingStep3: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xLarge) {
            Text("See a new Daily Shuffle each day.")
                .font(AppTheme.Typography.title)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            // Banner preview with chicken mascot
            VStack(spacing: AppTheme.Spacing.large) {
                // Mock daily banner
                HStack(spacing: AppTheme.Spacing.small) {
                    Text("🐔")
                        .font(.system(size: 32))
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                        Text("Daily Shuffle")
                            .font(AppTheme.Typography.bodyBold)
                            .foregroundColor(AppTheme.Colors.gold)
                        
                        Text("Tap to reveal today's combo")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .padding(AppTheme.Spacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                        .fill(AppTheme.Colors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                                .stroke(AppTheme.Colors.gold.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: AppTheme.Colors.gold.opacity(0.1), radius: 10)
            }
        }
        .padding(.horizontal, AppTheme.Layout.screenPadding)
    }
}

struct CategoryToggle: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(category.icon)
                    .font(.system(size: 26))
                
                Text(category.rawValue)
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? AppTheme.Colors.categoryColor(for: category) : AppTheme.Colors.textTertiary)
                    .font(.system(size: 24))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
            .padding(AppTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                    .fill(AppTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                            .stroke(
                                isSelected ? AppTheme.Colors.categoryColor(for: category).opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingView()
}