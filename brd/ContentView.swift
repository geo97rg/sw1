import SwiftUI

struct ContentView: View {
    @StateObject private var storageManager = StorageManager.shared
    @State private var selectedTab = 0
    @State private var showSettings = false
    
    init() {
        // Настройка навигационного бара
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(AppTheme.Colors.navigationBackground)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.Colors.headerText),
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.Colors.headerText)
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Настройка таб бара
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(AppTheme.Colors.navigationBackground)
        
        // Настройка цветов элементов таб бара
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.Colors.textTertiary)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.Colors.textTertiary)
        ]
        
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.Colors.emberOrange)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.Colors.emberOrange)
        ]
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some View {
        if !storageManager.hasCompletedOnboarding {
            OnboardingView()
        } else {
            ZStack {
                TabView(selection: $selectedTab) {
                    ShuffleView(showSettings: $showSettings)
                        .tabItem {
                            Label("Shuffle", systemImage: AppTheme.Icons.shuffle)
                        }
                        .tag(0)
                    
                    StoryView(showSettings: $showSettings)
                        .tabItem {
                            Label("Story", systemImage: AppTheme.Icons.story)
                        }
                        .tag(1)
                    
                    MixView(showSettings: $showSettings)
                        .tabItem {
                            Label("Mix", systemImage: AppTheme.Icons.mix)
                        }
                        .tag(2)
                    
                    ChallengeView(showSettings: $showSettings)
                        .tabItem {
                            Label("Challenge", systemImage: AppTheme.Icons.challenge)
                        }
                        .tag(3)
                    
                    FavoritesView(showSettings: $showSettings)
                        .tabItem {
                            Label("Favorites", systemImage: AppTheme.Icons.favorites)
                        }
                        .tag(4)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }
            .background(AppTheme.Colors.backgroundPrimary)
        }
    }
}

#Preview {
    ContentView()
}
