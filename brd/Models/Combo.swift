import Foundation

struct Combo: Identifiable, Codable, Equatable {
    let id: UUID
    let items: [ComboItem]
    let createdAt: Date
    
    init(items: [ComboItem], createdAt: Date = Date()) {
        self.id = UUID()
        self.items = items
        self.createdAt = createdAt
    }
    
    var shareText: String {
        let itemTexts = items.map { "\($0.category.icon) \($0.category.rawValue): \($0.value)" }
        return itemTexts.joined(separator: "\n")
    }
    
    var shortDescription: String {
        items.map { $0.value }.joined(separator: " + ")
    }
}

struct ComboItem: Codable, Equatable {
    let category: Category
    let value: String
    
    init(category: Category, value: String) {
        self.category = category
        self.value = value
    }
}