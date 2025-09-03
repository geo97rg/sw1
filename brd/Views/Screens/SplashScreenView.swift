import SwiftUI

struct SplashScreenView: View {
   
    
    var body: some View {
        ZStack {
            // Beautiful themed background gradient
            LinearGradient(
                colors: [
                    AppTheme.Colors.backgroundPrimary,
                    AppTheme.Colors.backgroundSecondary,
                    AppTheme.Colors.cardBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.xLarge) {
                Spacer()
                
                // Main app icon/logo area with timer
                ZStack {
                    
                    
                    // App icon container with timer progress
                    ZStack {
                        // Background circle for timer
                        
                        
                        // App symbol - dice icon
                        Image(systemName: AppTheme.Icons.shuffle)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.emberOrange,
                                        AppTheme.Colors.gold
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                // Loading indicator
                HStack(spacing: AppTheme.Spacing.xSmall) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(AppTheme.Colors.emberOrange)
                            .frame(width: 8, height: 8)
                            .scaleEffect(true ? 1.0 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: true
                            )
                    }
                }
                .opacity(true ? 1.0 : 0.0)
                .animation(
                    .easeIn(duration: 0.5)
                    .delay(1.0),
                    value: true
                )
                
                Spacer()
            }
        }
        .onAppear {
            
        }
    }
}
