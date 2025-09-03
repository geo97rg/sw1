import Foundation

enum Category: String, CaseIterable, Codable {
    case character = "Character"
    case setting = "Setting"
    case goal = "Goal"
    case twist = "Twist"
    
    var icon: String {
        switch self {
        case .character:
            return "🐔"
        case .setting:
            return "🏰"
        case .goal:
            return "🎯"
        case .twist:
            return "⚡"
        }
    }
    
    var colorName: String {
        switch self {
        case .character:
            return "gold"
        case .setting:
            return "ember"
        case .goal:
            return "fire"
        case .twist:
            return "magic"
        }
    }
}