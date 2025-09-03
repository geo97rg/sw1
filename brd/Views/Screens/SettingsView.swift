import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storageManager = StorageManager.shared
    @State private var challengeDurations: [Int] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xLarge) {
                        // Appearance & Language
                        SettingsSection(title: "Appearance & Language") {
                            VStack(spacing: AppTheme.Spacing.xSmall) {
                                SettingsRow(
                                    label: "Language", 
                                    value: "English",
                                    note: "Fixed"
                                )
                                
                                Divider()
                                    .background(AppTheme.Colors.divider)
                                
                                SettingsRow(
                                    label: "Theme", 
                                    value: "Dungeon",
                                    note: "Fixed"
                                )
                            }
                            .padding(AppTheme.Spacing.medium)
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(AppTheme.Layout.smallCornerRadius)
                        }
                        
                        // Categories
                        SettingsSection(title: "Categories") {
                            VStack(spacing: AppTheme.Spacing.small) {
                                ForEach(Category.allCases, id: \.self) { category in
                                    CategoryToggleRow(
                                        category: category,
                                        isEnabled: storageManager.isCategoryEnabled(category),
                                        action: {
                                            storageManager.toggleCategory(category)
                                        }
                                    )
                                }
                            }
                            .padding(AppTheme.Spacing.medium)
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(AppTheme.Layout.smallCornerRadius)
                            
                            Text("Affects default categories in Shuffle/Story modes")
                                .font(AppTheme.Typography.footnote)
                                .foregroundColor(AppTheme.Colors.textTertiary)
                                .padding(.top, AppTheme.Spacing.xSmall)
                        }
                        
                        // Challenge
                        SettingsSection(title: "Challenge") {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                                DurationEditor(durations: $challengeDurations)
                            }
                            .padding(AppTheme.Spacing.medium)
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(AppTheme.Layout.smallCornerRadius)
                        }
                        
                        // About
                        SettingsSection(title: "About") {
                            VStack(spacing: AppTheme.Spacing.small) {
                                HStack {
                                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                                        Text("Brainstorm Dice")
                                            .font(AppTheme.Typography.bodyBold)
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                        
                                        Text("Version 1.0.0")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("🐔")
                                        .font(.system(size: 32))
                                }
                                
                                Divider()
                                    .background(AppTheme.Colors.divider)
                                
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                                    Text("Made with a brave chicken")
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    
                                    Text("Roll the dice for creative inspiration")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                                
                                Divider()
                                    .background(AppTheme.Colors.divider)
                                
                                HStack {
                                    Text("Credits")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text("🐔 Chicken Team")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.Colors.gold)
                                }
                            }
                            .padding(AppTheme.Spacing.medium)
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(AppTheme.Layout.smallCornerRadius)
                        }
                    }
                    .padding(AppTheme.Layout.screenPadding)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Save challenge durations when closing
                        storageManager.saveChallengeDurations(challengeDurations)
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.headerText)
                }
            }
        }
        .onAppear {
            challengeDurations = storageManager.challengeDurations
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text(title)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.headerText)
            
            content
        }
    }
}

struct SettingsRow: View {
    let label: String
    let value: String
    let note: String?
    
    init(label: String, value: String, note: String? = nil) {
        self.label = label
        self.value = value
        self.note = note
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
            
            HStack(spacing: AppTheme.Spacing.xSmall) {
                Text(value)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                if let note = note {
                    Text("(\(note))")
                        .font(AppTheme.Typography.footnote)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.xxSmall)
    }
}

struct CategoryToggleRow: View {
    let category: Category
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                Text(category.icon)
                    .font(.system(size: 22))
                
                Text(category.rawValue)
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Image(systemName: isEnabled ? "checkmark.square.fill" : "square")
                    .foregroundColor(
                        isEnabled 
                        ? AppTheme.Colors.categoryColor(for: category)
                        : AppTheme.Colors.textTertiary
                    )
                    .font(.system(size: 22))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
            }
            .padding(.vertical, AppTheme.Spacing.xSmall)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}