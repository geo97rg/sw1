import Foundation
import SwiftUI

class ShuffleViewModel: ObservableObject {
    @Published var currentCombo: Combo?
    @Published var isRolling = false
    @Published var showSaveConfirmation = false
    @Published var showRemoveConfirmation = false
    @Published var showRollSuccess = false
    
    private let storageManager = StorageManager.shared
    private let contentGenerator = ContentGenerator.shared
    
    func roll() {
        withAnimation(.rollAnimation) {
            isRolling = true
        }
        
        // Generate combo based on enabled categories
        let enabledCategories = Array(storageManager.enabledCategories)
        guard !enabledCategories.isEmpty else { return }
        
        // Simulate dice roll animation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.currentCombo = self?.contentGenerator.generateCombo(categories: enabledCategories)
            withAnimation(.spring()) {
                self?.isRolling = false
            }
            
            // Show roll success message
            withAnimation {
                self?.showRollSuccess = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                withAnimation {
                    self?.showRollSuccess = false
                }
            }
        }
    }
    
    func save() {
        guard let combo = currentCombo else { return }
        
        if storageManager.isFavorite(combo) {
            // Remove from favorites
            storageManager.removeFavorite(combo)
            
            // Show remove confirmation
            withAnimation {
                showRemoveConfirmation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                withAnimation {
                    self?.showRemoveConfirmation = false
                }
            }
        } else {
            // Add to favorites
            storageManager.saveFavorite(combo)
            
            // Show save confirmation
            withAnimation {
                showSaveConfirmation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                withAnimation {
                    self?.showSaveConfirmation = false
                }
            }
        }
    }
    
    func shareCombo() -> String {
        guard let combo = currentCombo else { return "" }
        return """
        Brainstorm Dice Roll:
        
        \(combo.shareText)
        
        Created with Brainstorm Dice 🐔
        """
    }
    
    func isFavorite() -> Bool {
        guard let combo = currentCombo else { return false }
        return storageManager.isFavorite(combo)
    }
}