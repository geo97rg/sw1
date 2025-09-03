import SwiftUI

struct FavoriteDetailView: View {
    let favorite: Favorite
    @Environment(\.dismiss) private var dismiss
    @State private var noteText: String
    @State private var showingDeleteAlert = false
    @State private var showSaveConfirmation = false
    
    private let storageManager = StorageManager.shared
    
    private var shareText: String {
        let noteText = noteText.isEmpty ? "" : "\n\nNote: \(noteText)"
        
        return """
        \(favorite.combo.shareText)\(noteText)
        
        Saved on \(favorite.dateString)
        Created with Brainstorm Dice 🐔
        """
    }
    
    init(favorite: Favorite) {
        self.favorite = favorite
        self._noteText = State(initialValue: favorite.note)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        // Saved date
                        HStack {
                            Text("Saved on \(favorite.dateString)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.textTertiary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        .padding(.top, AppTheme.Spacing.small)
                        
                        // Combo card
                        ComboCard(combo: favorite.combo, isRolling: false)
                            .padding(.horizontal, AppTheme.Layout.screenPadding)
                        
                        // Note section
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                            HStack {
                                Text("Note:")
                                    .font(AppTheme.Typography.bodyBold)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                
                                Spacer()
                                
                                Text("\(noteText.count)/280")
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundColor(
                                        noteText.count > 280 
                                        ? AppTheme.Colors.fireRed
                                        : AppTheme.Colors.textTertiary
                                    )
                            }
                            
                            // Text editor
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                                    .fill(AppTheme.Colors.cardBackground)
                                    .frame(minHeight: 120)
                                
                                if noteText.isEmpty {
                                    Text("Add your thoughts, ideas, or inspiration...")
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                        .padding(AppTheme.Spacing.medium)
                                        .allowsHitTesting(false)
                                }
                                
                                TextEditor(text: $noteText)
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                    .scrollContentBackground(.hidden)
                                    .padding(AppTheme.Spacing.medium)
                                    .frame(minHeight: 120)
                                    .onChange(of: noteText) { oldValue, newValue in
                                        // Limit to 280 characters
                                        if newValue.count > 280 {
                                            noteText = String(newValue.prefix(280))
                                        }
                                    }
                            }
                            
                            // Save Note button
                            Button(action: {
                                storageManager.updateFavoriteNote(id: favorite.id, note: noteText)
                                showSaveConfirmation = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showSaveConfirmation = false
                                }
                            }) {
                                HStack(spacing: AppTheme.Spacing.xSmall) {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 16))
                                    Text("Save Note")
                                        .font(AppTheme.Typography.buttonLabel)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonModifier())
                            .disabled(noteText == favorite.note)
                            .opacity(noteText == favorite.note ? 0.6 : 1.0)
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        
                        // Action buttons
                        VStack(spacing: AppTheme.Spacing.medium) {
                            // Share button
                            ShareLink(item: shareText) {
                                HStack(spacing: AppTheme.Spacing.xSmall) {
                                    Image(systemName: AppTheme.Icons.share)
                                        .font(.system(size: 16))
                                    Text("Share")
                                        .font(AppTheme.Typography.buttonLabel)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryButtonModifier())
                            
                            // Delete button
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                HStack(spacing: AppTheme.Spacing.xSmall) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                    Text("Delete")
                                        .font(AppTheme.Typography.buttonLabel)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryButtonModifier())
                            .foregroundColor(AppTheme.Colors.fireRed)
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                        .padding(.bottom, AppTheme.Spacing.large)
                    }
                }
                
                // Save confirmation toast
                if showSaveConfirmation {
                    ToastView(
                        icon: "checkmark.circle.fill",
                        message: "Saved.",
                        iconColor: AppTheme.Colors.gold
                    )
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("Favorite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.emberOrange)
                }
            }
        }
        .alert("Remove from Favorites?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                storageManager.deleteFavorite(id: favorite.id)
                dismiss()
            }
        } message: {
            Text("This favorite will be permanently deleted.")
        }
        .hideKeyboardOnTap()
    }
}

#Preview {
    FavoriteDetailView(
        favorite: Favorite(
            combo: Combo(items: [
                ComboItem(category: .character, value: "a torch-bearing chicken"),
                ComboItem(category: .setting, value: "an ember-lit dungeon"),
                ComboItem(category: .goal, value: "to relight the last torch"),
                ComboItem(category: .twist, value: "under flickering torchlight")
            ]),
            note: "This is a great combo for a fantasy adventure story!"
        )
    )
}