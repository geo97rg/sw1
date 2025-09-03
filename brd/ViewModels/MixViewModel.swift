import Foundation
import SwiftUI

class MixViewModel: ObservableObject {
    @Published var selectedCategories: Set<Category> = [.character, .setting, .goal]
    @Published var lastCombo: Combo?
    @Published var isRolling = false
    @Published var showSaveConfirmation = false
    
    private let contentGenerator = ContentGenerator.shared
    private let storageManager = StorageManager.shared
    
    var canRoll: Bool {
        !selectedCategories.isEmpty
    }
    
    var canSaveLast: Bool {
        lastCombo != nil
    }
    
    var validationMessage: String? {
        if selectedCategories.isEmpty {
            return "At least one category must be selected"
        }
        return nil
    }
    
    func toggleCategory(_ category: Category) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedCategories.contains(category) {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
        }
    }
    
    func isCategorySelected(_ category: Category) -> Bool {
        selectedCategories.contains(category)
    }
    
    func rollSelected() {
        guard canRoll else { return }
        
        withAnimation {
            isRolling = true
        }
        
        // Generate combo with selected categories in fixed order
        let orderedCategories = Category.allCases.filter { selectedCategories.contains($0) }
        
        // Simulate rolling delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.lastCombo = self?.contentGenerator.generateCombo(categories: orderedCategories)
            
            withAnimation(.spring()) {
                self?.isRolling = false
            }
        }
    }
    
    func saveLast() {
        guard let combo = lastCombo else { return }
        
        if storageManager.isFavorite(combo) {
            // Remove from favorites
            storageManager.removeFavorite(combo)
        } else {
            // Add to favorites
            storageManager.saveFavorite(combo)
        }
        
        withAnimation {
            showSaveConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            withAnimation {
                self?.showSaveConfirmation = false
            }
        }
    }
    
    func shareCombo() -> String {
        guard let combo = lastCombo else { return "" }
        return """
        Mix Mode Combo:
        
        \(combo.shareText)
        
        Created with Brainstorm Dice 🐔
        """
    }
    
    func isLastComboFavorite() -> Bool {
        guard let combo = lastCombo else { return false }
        return storageManager.isFavorite(combo)
    }
    
    func getSelectedCategoriesText() -> String {
        let sortedCategories = Category.allCases.filter { selectedCategories.contains($0) }
        return sortedCategories.map { $0.rawValue }.joined(separator: ", ")
    }
}