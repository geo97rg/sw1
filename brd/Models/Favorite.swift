import Foundation

struct Favorite: Identifiable, Codable {
    let id: UUID
    let combo: Combo
    var note: String
    let savedAt: Date
    
    init(combo: Combo, note: String = "", savedAt: Date = Date()) {
        self.id = UUID()
        self.combo = combo
        self.note = note
        self.savedAt = savedAt
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: savedAt)
    }
}