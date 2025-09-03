import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                if viewModel.hasNoFavorites {
                    emptyState
                } else {
                    mainContent
                }
            }
            .navigationTitle("Favorites")
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
            .alert("Remove from Favorites?", isPresented: $viewModel.showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    viewModel.confirmDelete()
                }
            } message: {
                Text("This favorite will be permanently deleted.")
            }
            .overlay(
                Group {
                    if viewModel.showDeleteConfirmation {
                        ToastView(
                            icon: "trash.fill",
                            message: "Removed.",
                            iconColor: AppTheme.Colors.fireRed
                        )
                        .padding(.bottom, 100)
                    }
                }
            )
        }
        .hideKeyboardOnTap()
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Text("🐔")
                .font(.system(size: 80))
                .opacity(0.5)
            
            Text("No favorites yet.")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Roll something great and tap ★ Save.")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppTheme.Layout.screenPadding)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Search and filters
            VStack(spacing: AppTheme.Spacing.medium) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .font(.system(size: 16))
                    
                    TextField("type to search…", text: $viewModel.searchText)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.small)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.Layout.smallCornerRadius)
                .padding(.horizontal, AppTheme.Layout.screenPadding)
                
                // Filter buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.small) {
                        ForEach(FavoriteFilter.allCases, id: \.self) { filter in
                            FilterButton(
                                title: filter.rawValue,
                                isSelected: viewModel.selectedFilter == filter,
                                action: {
                                    viewModel.setFilter(filter)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.screenPadding)
                }
            }
            .padding(.top, AppTheme.Spacing.small)
            
            Divider()
                .background(AppTheme.Colors.divider)
                .padding(.vertical, AppTheme.Spacing.small)
            
            // Results
            if viewModel.hasNoFilteredResults {
                noResultsState
            } else {
                favoritesContent
            }
        }
    }
    
    @ViewBuilder
    private var noResultsState: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Text("🔍")
                .font(.system(size: 60))
                .opacity(0.3)
            
            Text("No results found")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Try adjusting your search or filters")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, AppTheme.Layout.screenPadding)
    }
    
    @ViewBuilder
    private var favoritesContent: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.medium) {
                ForEach(viewModel.filteredFavorites) { favorite in
                    NavigationLink(destination: FavoriteDetailView(favorite: favorite)) {
                        FavoriteRow(
                            favorite: favorite,
                            onDelete: {
                                viewModel.deleteFavorite(favorite)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(AppTheme.Layout.screenPadding)
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(
                    isSelected 
                    ? .white 
                    : AppTheme.Colors.textPrimary
                )
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.vertical, AppTheme.Spacing.xSmall)
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
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct FavoriteRow: View {
    let favorite: Favorite
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack {
                Text("• \(favorite.dateString)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                
                Spacer()
                
                // Context menu button
                Menu {
                    Button(action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            
            Text(favorite.combo.shortDescription)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Show note preview if exists
            if !favorite.note.isEmpty {
                Text(favorite.note)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
                    .italic()
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.Layout.smallCornerRadius)
        .shadow(
            color: AppTheme.Shadows.softShadowColor,
            radius: AppTheme.Shadows.softShadowRadius,
            x: AppTheme.Shadows.softShadowX,
            y: AppTheme.Shadows.softShadowY
        )
    }
}

#Preview {
    FavoritesView(showSettings: .constant(false))
}