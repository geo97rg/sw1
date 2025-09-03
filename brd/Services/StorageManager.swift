import Foundation
import SwiftUI

class StorageManager: ObservableObject {
    static let shared = StorageManager()
    
    private let favoritesKey = "brd_favorites"
    private let onboardingKey = "brd_onboarding_completed"
    private let enabledCategoriesKey = "brd_enabled_categories"
    private let challengeDurationsKey = "brd_challenge_durations"
    private let includeTwistInStoryKey = "brd_include_twist_story"
    private let lastDailyDateKey = "brd_last_daily_date"
    private let dailyComboKey = "brd_daily_combo"
    
    @Published var favorites: [Favorite] = []
    @Published var hasCompletedOnboarding: Bool = false
    @Published var enabledCategories: Set<Category> = Set(Category.allCases)
    @Published var challengeDurations: [Int] = [15, 30, 60, 120]
    @Published var includeTwistInStory: Bool = false
    
    private init() {
        loadAll()
    }
    
    // MARK: - Favorites
    func saveFavorite(_ combo: Combo, note: String = "") {
        let favorite = Favorite(combo: combo, note: note)
        favorites.append(favorite)
        saveFavorites()
    }
    
    func updateFavoriteNote(id: UUID, note: String) {
        if let index = favorites.firstIndex(where: { $0.id == id }) {
            favorites[index].note = note
            saveFavorites()
        }
    }
    
    func deleteFavorite(id: UUID) {
        favorites.removeAll { $0.id == id }
        saveFavorites()
    }
    
    func removeFavorite(_ combo: Combo) {
        favorites.removeAll { $0.combo == combo }
        saveFavorites()
    }
    
    func isFavorite(_ combo: Combo) -> Bool {
        favorites.contains { $0.combo == combo }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Favorite].self, from: data) {
            favorites = decoded
        }
    }
    
    // MARK: - Onboarding
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    private func loadOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    // MARK: - Categories
    func toggleCategory(_ category: Category) {
        if enabledCategories.contains(category) {
            // Ensure at least one category remains enabled
            if enabledCategories.count > 1 {
                enabledCategories.remove(category)
            }
        } else {
            enabledCategories.insert(category)
        }
        saveEnabledCategories()
    }
    
    func isCategoryEnabled(_ category: Category) -> Bool {
        enabledCategories.contains(category)
    }
    
    private func saveEnabledCategories() {
        let categoriesArray = Array(enabledCategories).map { $0.rawValue }
        UserDefaults.standard.set(categoriesArray, forKey: enabledCategoriesKey)
    }
    
    private func loadEnabledCategories() {
        if let categoriesArray = UserDefaults.standard.stringArray(forKey: enabledCategoriesKey) {
            enabledCategories = Set(categoriesArray.compactMap { Category(rawValue: $0) })
        } else {
            enabledCategories = Set(Category.allCases)
        }
    }
    
    // MARK: - Challenge Durations
    func saveChallengeDurations(_ durations: [Int]) {
        challengeDurations = durations
        UserDefaults.standard.set(durations, forKey: challengeDurationsKey)
    }
    
    private func loadChallengeDurations() {
        if let durations = UserDefaults.standard.array(forKey: challengeDurationsKey) as? [Int] {
            challengeDurations = durations
        }
    }
    
    // MARK: - Story Mode Settings
    func toggleTwistInStory() {
        includeTwistInStory.toggle()
        UserDefaults.standard.set(includeTwistInStory, forKey: includeTwistInStoryKey)
    }
    
    private func loadStorySettings() {
        includeTwistInStory = UserDefaults.standard.bool(forKey: includeTwistInStoryKey)
    }
    
    // MARK: - Daily Combo
    func getDailyCombo() -> Combo? {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDailyDate = UserDefaults.standard.object(forKey: lastDailyDateKey) as? Date
        
        // Check if we need a new daily combo
        if lastDailyDate != today {
            // Generate new daily combo
            let dailyCombo = ContentGenerator.shared.generateDailyCombo(for: today)
            
            // Save the combo and date
            if let encoded = try? JSONEncoder().encode(dailyCombo) {
                UserDefaults.standard.set(encoded, forKey: dailyComboKey)
                UserDefaults.standard.set(today, forKey: lastDailyDateKey)
            }
            
            return dailyCombo
        } else {
            // Return existing daily combo
            if let data = UserDefaults.standard.data(forKey: dailyComboKey),
               let combo = try? JSONDecoder().decode(Combo.self, from: data) {
                return combo
            }
        }
        
        return nil
    }
    
    // MARK: - Load All
    private func loadAll() {
        loadFavorites()
        loadOnboardingStatus()
        loadEnabledCategories()
        loadChallengeDurations()
        loadStorySettings()
    }
}