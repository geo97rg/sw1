import Foundation
import SwiftUI

class StoryViewModel: ObservableObject {
    @Published var storyCombo: Combo?
    @Published var includeTwist: Bool = false
    @Published var isGenerating = false
    @Published var showSaveConfirmation = false
    @Published var cardsVisible: [Bool] = [false, false, false, false]
    
    private let storageManager = StorageManager.shared
    private let contentGenerator = ContentGenerator.shared
    
    init() {
        self.includeTwist = storageManager.includeTwistInStory
    }
    
    func rebuild() {
        withAnimation {
            isGenerating = true
            // Hide all cards first
            cardsVisible = [false, false, false, false]
        }
        
        // Generate story based on fixed order
        var categories: [Category] = [.character, .setting, .goal]
        if includeTwist {
            categories.append(.twist)
        }
        
        storyCombo = contentGenerator.generateCombo(categories: categories)
        
        // Animate cards appearing sequentially
        for index in 0..<categories.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) { [weak self] in
                withAnimation(.slideUp) {
                    self?.cardsVisible[index] = true
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(categories.count) * 0.15) { [weak self] in
            withAnimation {
                self?.isGenerating = false
            }
        }
    }
    
    func toggleTwist() {
        withAnimation {
            includeTwist.toggle()
            storageManager.toggleTwistInStory()
            
            if includeTwist && storyCombo != nil {
                // Add twist to existing combo
                if let twistValue = contentGenerator.generateValue(for: .twist) {
                    var items = storyCombo?.items ?? []
                    items.append(ComboItem(category: .twist, value: twistValue))
                    storyCombo = Combo(items: items)
                    
                    // Animate the twist card appearing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        withAnimation(.slideUp) {
                            self?.cardsVisible[3] = true
                        }
                    }
                }
            } else if !includeTwist && storyCombo != nil {
                // Remove twist from combo
                var items = storyCombo?.items ?? []
                items.removeAll { $0.category == .twist }
                
                // Hide the twist card first
                withAnimation(.easeOut(duration: 0.2)) {
                    cardsVisible[3] = false
                }
                
                // Then update the combo
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.storyCombo = Combo(items: items)
                }
            }
        }
    }
    
    func save() {
        guard let combo = storyCombo else { return }
        
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
        guard let combo = storyCombo else { return "" }
        return """
        Story Mode Combo:
        
        \(combo.shareText)
        
        Created with Brainstorm Dice 🐔
        """
    }
    
    func isFavorite() -> Bool {
        guard let combo = storyCombo else { return false }
        return storageManager.isFavorite(combo)
    }
}