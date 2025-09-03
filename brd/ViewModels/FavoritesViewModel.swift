import Foundation
import SwiftUI

class FavoritesViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedFilter: FavoriteFilter = .all
    @Published var showingDeleteAlert = false
    @Published var favoriteToDelete: Favorite?
    @Published var showSaveNoteConfirmation = false
    @Published var showDeleteConfirmation = false
    
    private let storageManager = StorageManager.shared
    
    var filteredFavorites: [Favorite] {
        var favorites = storageManager.favorites
        
        // Apply category filter
        if selectedFilter != .all {
            favorites = favorites.filter { favorite in
                favorite.combo.items.contains { item in
                    item.category == selectedFilter.category
                }
            }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            favorites = favorites.filter { favorite in
                // Search in combo values
                let comboText = favorite.combo.items.map { $0.value }.joined(separator: " ").lowercased()
                let noteText = favorite.note.lowercased()
                let searchLower = searchText.lowercased()
                
                return comboText.contains(searchLower) || noteText.contains(searchLower)
            }
        }
        
        // Sort by date (newest first)
        return favorites.sorted { $0.savedAt > $1.savedAt }
    }
    
    var hasNoFavorites: Bool {
        storageManager.favorites.isEmpty
    }
    
    var hasNoFilteredResults: Bool {
        !hasNoFavorites && filteredFavorites.isEmpty
    }
    
    func setFilter(_ filter: FavoriteFilter) {
        selectedFilter = filter
    }
    
    func deleteFavorite(_ favorite: Favorite) {
        favoriteToDelete = favorite
        showingDeleteAlert = true
    }
    
    func confirmDelete() {
        guard let favorite = favoriteToDelete else { return }
        storageManager.deleteFavorite(id: favorite.id)
        favoriteToDelete = nil
        showingDeleteAlert = false
        
        // Show removal confirmation
        withAnimation {
            showDeleteConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation {
                self?.showDeleteConfirmation = false
            }
        }
    }
    
    func updateNote(for favoriteId: UUID, note: String) {
        storageManager.updateFavoriteNote(id: favoriteId, note: note)
        
        withAnimation {
            showSaveNoteConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation {
                self?.showSaveNoteConfirmation = false
            }
        }
    }
    
    func shareText(for favorite: Favorite) -> String {
        let noteText = favorite.note.isEmpty ? "" : "\n\nNote: \(favorite.note)"
        
        return """
        \(favorite.combo.shareText)\(noteText)
        
        Saved on \(favorite.dateString)
        Created with Brainstorm Dice 🐔
        """
    }
}

enum FavoriteFilter: String, CaseIterable {
    case all = "All"
    case character = "Character"
    case setting = "Setting"
    case goal = "Goal"
    case twist = "Twist"
    
    var category: Category? {
        switch self {
        case .all:
            return nil
        case .character:
            return .character
        case .setting:
            return .setting
        case .goal:
            return .goal
        case .twist:
            return .twist
        }
    }
}