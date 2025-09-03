import Foundation
import SwiftUI

class DailyManager: ObservableObject {
    static let shared = DailyManager()
    
    @Published var dailyCombo: Combo?
    @Published var isDailyRevealed: Bool = false
    
    private let dailyRevealedKey = "brd_daily_revealed_date"
    
    private init() {
        checkDailyStatus()
    }
    
    func checkDailyStatus() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastRevealedDate = UserDefaults.standard.object(forKey: dailyRevealedKey) as? Date
        
        // Reset reveal status if it's a new day
        if lastRevealedDate != today {
            isDailyRevealed = false
            dailyCombo = nil
        } else {
            // Load the daily combo if it was already revealed today
            isDailyRevealed = true
            dailyCombo = StorageManager.shared.getDailyCombo()
        }
    }
    
    func revealDaily() {
        guard !isDailyRevealed else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        dailyCombo = StorageManager.shared.getDailyCombo()
        isDailyRevealed = true
        
        // Save reveal date
        UserDefaults.standard.set(today, forKey: dailyRevealedKey)
    }
    
    func getDailyDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }
}