import Foundation
import SwiftUI

class ChallengeViewModel: ObservableObject {
    @Published var currentCombo: Combo?
    @Published var selectedDuration: Int = 60
    @Published var challengeState: ChallengeState = .setup
    @Published var timeRemaining: Int = 0
    @Published var showSaveConfirmation = false
    @Published var timerPulse = false
    
    private var timer: Timer?
    private let storageManager = StorageManager.shared
    private let contentGenerator = ContentGenerator.shared
    
    var availableDurations: [Int] {
        storageManager.challengeDurations
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var resultMessage: String {
        switch challengeState {
        case .completed:
            return "Challenge finished."
        case .gaveUp:
            return "Maybe next time."
        default:
            return ""
        }
    }
    
    init() {
        generateNewCombo()
    }
    
    func selectDuration(_ duration: Int) {
        selectedDuration = duration
    }
    
    func generateNewCombo() {
        currentCombo = contentGenerator.generateCombo(categories: Category.allCases)
    }
    
    func startChallenge() {
        guard challengeState == .setup else { return }
        
        timeRemaining = selectedDuration
        challengeState = .running
        startTimer()
    }
    
    func completeChallenge() {
        stopTimer()
        challengeState = .completed
    }
    
    func giveUp() {
        stopTimer()
        challengeState = .gaveUp
    }
    
    func tryAnother() {
        stopTimer()
        generateNewCombo()
        challengeState = .setup
        timeRemaining = 0
    }
    
    func backToSetup() {
        stopTimer()
        challengeState = .setup
        timeRemaining = 0
    }
    
    func saveChallenge() {
        guard let combo = currentCombo else { return }
        
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
        guard let combo = currentCombo else { return "" }
        return """
        Challenge Mode:
        Duration: \(selectedDuration)s
        
        \(combo.shareText)
        
        Created with Brainstorm Dice 🐔
        """
    }
    
    func isFavorite() -> Bool {
        guard let combo = currentCombo else { return false }
        return storageManager.isFavorite(combo)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.timerTick()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerTick() {
        // Pulse animation every second
        withAnimation(.easeInOut(duration: 0.3)) {
            timerPulse.toggle()
        }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            // Time's up - automatically complete
            completeChallenge()
        }
    }
    
    deinit {
        stopTimer()
    }
}

enum ChallengeState {
    case setup
    case running
    case completed
    case gaveUp
}